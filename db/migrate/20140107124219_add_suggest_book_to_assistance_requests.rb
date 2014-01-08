class AddSuggestBookToAssistanceRequests < ActiveRecord::Migration
  def up
    add_column :assistance_requests, :book_suggest, :boolean, :default => false

    AssistanceRequest.connection.execute %q{
      update assistance_requests set book_suggest = false;
    }
  end

  def down
    remove_column :assistance_requests, :book_suggest
  end
end
