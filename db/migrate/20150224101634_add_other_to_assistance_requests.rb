class AddOtherToAssistanceRequests < ActiveRecord::Migration
  def change
    change_table :assistance_requests do |t|
      t.text :other_title
      t.text :other_author
      t.text :other_publisher
      t.text :other_doi
    end
  end
end
