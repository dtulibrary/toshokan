class SynchronizeOrderStatusWithRedmineIssue
  def initialize(order)
    @order = order
  end
  attr_reader :order

  def call
    latest_resolve_event = order.order_events.select { |oe| oe.name == "resolved" }.sort_by { |oe| [oe.created_at, oe.redmine_journal_entry_id] }.last

    if latest_resolve_event.nil?
      Rails.logger.info("SynchronizeOrderStatusWithRedmineIssue called for order (id=#{order.id}) but no 'resolved' event found. Nothing to do.")
      return
    end

    set_and_log_new_delivery_status = lambda do |new_delivery_status|
      order.delivery_status = new_delivery_status
      order.save!
      Rails.logger.info("Order (id=#{order.id}) delivery_status set to #{new_delivery_status}. Latest resolve event data is: #{latest_resolve_event.data}.")
    end

    do_nothing = lambda do
      Rails.logger.info("Not updating delivery_status of order (id=#{order.id}). Latest resolve event data is: #{latest_resolve_event.data}.")
    end

    if /^Terminated|^Rejected/.match(latest_resolve_event.data)
      set_and_log_new_delivery_status.call(:cancelled)
    elsif latest_resolve_event.data == "Duplicate request"
      set_and_log_new_delivery_status.call(:cancelled)
    elsif /^Success/.match(latest_resolve_event.data)
      set_and_log_new_delivery_status.call(:deliver)
    elsif ["TIB - Print", "TIB - DRM"].include?(latest_resolve_event.data)
      set_and_log_new_delivery_status.call(:deliver)
    elsif /^Other/.match(latest_resolve_event.data)
      do_nothing.call
    elsif latest_resolve_event.data == "" # 'resolve' event 'deleted' in Redmine
      # TODO TLNI: This is not what we want to do ...
      do_nothing.call
    elsif latest_resolve_event.data == "Request transfered to ILL in Aleph"
      do_nothing.call
    else
      do_nothing.call
    end
  end
end
