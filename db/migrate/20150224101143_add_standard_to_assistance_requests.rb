class AddStandardToAssistanceRequests < ActiveRecord::Migration
  def change
    change_table :assistance_requests do |t|
      t.text :standard_title
      t.text :standard_subtitle
      t.text :standard_publisher
      t.text :standard_doi
      t.text :standard_number
      t.text :standard_isbn
      t.text :standard_year
      t.text :standard_pages
    end
  end
end
