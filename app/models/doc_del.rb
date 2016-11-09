require 'httparty'

class DocDel
  include Configured

  def self.show order_id
    response = HTTParty.get "#{DocDel.url}/rest/orders/#{order_id}.json"
    if response.code == 200
      ActiveSupport::JSON.decode response.body
    else
      Rails.logger.error "Error getting DocDel order with id = #{order_id}:\nResponse: HTTP #{response.code}\nResponse body:\n#{response.body}"
    end
  end

  def self.request_delivery order, callback_url, options = {}
    supplier_map = {
      :rd => :reprintsdesk,
      :dtu => :local_scan
    }

    params = {
      :dibs_order_id => order.dibs_order_id,
      :open_url => order.open_url,
      :supplier => supplier_map[order.supplier] || order.supplier,
      :email => order.email,
      :callback_url => callback_url
    }

    params[:findit_user_type] = order.user.type if order.user
    params[:user_id] = order.user.identifier if order.user
    params[:timecap_base] = options[:timecap_base] || Time.now.iso8601

    Rails.logger.info "Sending order to DocDel (timing out in #{DocDel.timeout} seconds):\nURL = #{DocDel.url},\nparams = #{params}"

    save_order = false
    begin
      if order.delivery_status == :initiated && order.docdel_order_id.nil?
        response = HTTParty.post "#{DocDel.url}/rest/orders.json", :timeout => DocDel.timeout, :body => params
      end

      if order.delivery_status != :initiated && !order.docdel_order_id.nil?
        response = HTTParty.put "#{DocDel.url}/rest/orders/#{order.docdel_order_id}.json", :timeout => DocDel.timeout, :body => params
      end

      if !((order.delivery_status == :initiated && order.docdel_order_id.nil?) || (order.delivery_status != :initiated && !order.docdel_order_id.nil?))
        Rails.logger.info "Delivery of an order which does not satisfy ((order.delivery_status == :initiated && order.docdel_order_id.nil?) || (order.delivery_status != :initiated && !order.docdel_order_id.nil?)) was requested. This should not happen. Order: #{order}. Params: #{params}."
      end
    rescue Net::ReadTimeout
      Rails.logger.error "Read DocDel response timed out after #{DocDel.timeout} seconds when posting delivery request to DocDel"
      # We miss the DocDel order id when timing out but we assume the order went through
      # so we don't end up ordering the same thing multiple times.
      save_order = true
    end

    if response.code == 200
      save_order = true
      remote_order = ActiveSupport::JSON.decode response.body
      order.docdel_order_id = remote_order['id']
    end

    if save_order
      is_redelivery = order.delivery_status == :reordered
      order.delivery_status = is_redelivery ? :redelivery_requested : :delivery_requested
      order.save!
      Rails.logger.info "Order (ID: #{order.id}) was saved"
    else
      Rails.logger.error "Error communicating with DocDel for order #{order.dibs_order_id}:\nResponse: HTTP #{response.code}\nResponse body:\n#{response.body}"
      raise "Error communicating with DocDel"
    end
  end
end
