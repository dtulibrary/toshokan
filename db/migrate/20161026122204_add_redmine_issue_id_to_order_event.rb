class AddRedmineIssueIdToOrderEvent < ActiveRecord::Migration
  def change
    add_column :order_events, :redmine_issue_id, :string
  end
end
