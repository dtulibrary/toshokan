class AddThesisToAssistanceRequests < ActiveRecord::Migration
  def change
    change_table :assistance_requests do |t|
      t.text :thesis_title
      t.text :thesis_author
      t.text :thesis_affiliation
      t.text :thesis_publisher
      t.text :thesis_type
      t.text :thesis_year
      t.text :thesis_pages
    end
  end
end
