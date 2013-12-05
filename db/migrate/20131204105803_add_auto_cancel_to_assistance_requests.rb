class AddAutoCancelToAssistanceRequests < ActiveRecord::Migration
  def up
    add_column :assistance_requests, :auto_cancel, :text, :default => 'never'

    AssistanceRequest.connection.execute %q{
      update assistance_requests set auto_cancel = 'never';
    }
  end

  def down
    remove_column :assistance_requests, :auto_cancel
  end
end
