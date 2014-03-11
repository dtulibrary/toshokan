class AddLibrarySupportIssueToAssistanceRequests < ActiveRecord::Migration
  def up
    add_column :assistance_requests, :library_support_issue, :text    
  end

  def down
    remove_column :assistance_requests, :library_support_issue
  end
end
