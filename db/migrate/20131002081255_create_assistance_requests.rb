class CreateAssistanceRequests < ActiveRecord::Migration
  def up
    create_table :assistance_requests do |t|
      t.string :type
      t.references :user

      t.text :article_title
      t.text :article_author
      t.text :article_doi

      t.text :journal_title
      t.text :journal_issn
      t.text :journal_volume
      t.text :journal_issue
      t.text :journal_year
      t.text :journal_pages

      t.text :proceedings_title
      t.text :proceedings_isxn
      t.text :proceedings_pages

      t.text :conference_title
      t.text :conference_location
      t.text :conference_year
      t.text :conference_number

      t.text :book_title
      t.text :book_author
      t.text :book_edition
      t.text :book_doi
      t.text :book_isbn
      t.text :book_year

      t.text :publisher_name

      t.text :notes
      
      t.text :email
      t.text :pickup_location
      t.text :physical_location

      t.timestamps
    end
  end

  def down
    drop_table :assistance_requests
  end
end
