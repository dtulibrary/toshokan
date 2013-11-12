class ChangeAssistanceRequests < ActiveRecord::Migration
  def up
    change_table :assistance_requests do |t|
      t.text :conference_isxn
      t.text :conference_pages
      t.text :book_publisher
    end
  
    AssistanceRequest.connection.execute %q{
      update assistance_requests set 
        conference_isxn  = proceedings_isxn,
        conference_pages = proceedings_pages,
        book_publisher   = publisher_name;
    }

    change_table :assistance_requests do |t|
      t.remove :conference_number
      t.remove :proceedings_title
      t.remove :proceedings_isxn
      t.remove :proceedings_pages
      t.remove :publisher_name
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
