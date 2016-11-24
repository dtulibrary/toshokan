class SynchronizeOrdersWithRedmineIssues
  def initialize(redmine_issue_repository = nil)
    @redmine_issue_repository = redmine_issue_repository || RedmineIssueRepository.new
  end

  def call
    @redmine_issue_repository.all_issue_ids.each do |redmine_issue_id|
      order = get_order_by_redmine_issue_id(redmine_issue_id)
      next if order.nil?

      journal_entries = @redmine_issue_repository.journal_entries(redmine_issue_id)
      journal_notes = @redmine_issue_repository.journal_notes(redmine_issue_id)

      events = (journal_notes.collect { |journal_note| map_journal_note_to_order_event(journal_note, order) } + journal_entries.collect { |journal_entry| map_journal_entry_to_order_event(journal_entry, order) }).reject { |order_event| order_event.nil? }
      events = remove_old_events(events, order)

      order.order_events.concat(events)
      order.save!
    end
  end

  private

  def get_order_by_redmine_issue_id(issue_id)
    null_order_event = Struct.new(:order).new(nil)
    (OrderEvent.where(:name => "delivery_manual", :data => issue_id.to_s).first || null_order_event).order
  end

  def remove_old_events(events, order)
    events.reject { |new_order_event| order.order_events.any? { |old_order_event| old_order_event.name == new_order_event.name && old_order_event.redmine_journal_entry_id == new_order_event.redmine_journal_entry_id } }
  end

  def map_journal_entry_to_order_event(journal_entry, order = nil)
    order_event_name = ""

    if "attr" == journal_entry["property"] && "status_id" == journal_entry["name"] && "Closed" == LibrarySupport.status_values[journal_entry["new_value"]]
      order_event_name = "closed"
      order_event_data = ""
    end

    if "attr" == journal_entry["property"] && "status_id" == journal_entry["name"] && "Requested/inprocess" == LibrarySupport.status_values[journal_entry["new_value"]]
      order_event_name = "requested_or_inprocess"
      order_event_data = ""
    end

    if "attr" == journal_entry["property"] && "status_id" == journal_entry["name"] && "Feedback - waiting" == LibrarySupport.status_values[journal_entry["new_value"]]
      order_event_name = "feedback_or_waiting"
      order_event_data = ""
    end

    if "cf" == journal_entry["property"] && "Delivery Request Resolved As" == map_custom_field_id_to_custom_field_name(journal_entry["name"])
      order_event_name = "resolved"
      order_event_data = journal_entry["new_value"]
    end

    if "cf" == journal_entry["property"] && "Document Supplier" == map_custom_field_id_to_custom_field_name(journal_entry["name"])
      order_event_name = "document_supplier_changed"
      order_event_data = journal_entry["new_value"]
    end

    return nil if "" == order_event_name

    OrderEvent.new({
      "order" => order,
      "created_at" => DateTime.parse(journal_entry["created_on"]),
      "name" => order_event_name,
      "data" => order_event_data,
      "redmine_issue_id" => journal_entry["issue_id"],
      "redmine_journal_entry_id" => journal_entry["journal_entry_id"],
    })
  end

  def map_custom_field_id_to_custom_field_name(custom_field_id)
    LibrarySupport.custom_fields
      .collect { |k,v| { v[:id] => v[:name] } }
      .inject({}) { |previous_value,id_name| previous_value.merge(id_name) }[custom_field_id] || ""
  end

  def map_journal_note_to_order_event(journal_note, order = nil)
    return nil if "" == journal_note["notes"]

    OrderEvent.new({
      "order" => order,
      "created_at" => DateTime.parse(journal_note["created_on"]),
      "name" => "note",
      "data" => journal_note["notes"],
      "redmine_journal_entry_id" => journal_note["id"],
      "redmine_issue_id" => journal_note["issue_id"]
    })
  end
end
