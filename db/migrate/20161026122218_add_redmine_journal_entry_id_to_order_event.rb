class AddRedmineJournalEntryIdToOrderEvent < ActiveRecord::Migration
  def change
    add_column :order_events, :redmine_journal_entry_id, :string
  end
end
