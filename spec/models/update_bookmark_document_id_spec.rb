require 'rails_helper'

describe UpdateBookmarkDocumentId do
  it "updates document_id of bookmark objects" do
    user = FactoryGirl.create :user
    old_document = SolrDocument.new(SolrDocument.unique_key => "1")
    new_document = SolrDocument.new(SolrDocument.unique_key => "2")
    bookmark = FactoryGirl.create :bookmark, :id => 1, :user => user, :document => old_document
    bookmark.save!

    UpdateBookmarkDocumentId.new("1", "2").call

    updated_bookmark = Bookmark.where(:id => 1).first
    expect(updated_bookmark.document_id).to eq("2")
  end

  it "does not throw any exceptions when no bookmarks are to be updated" do
    UpdateBookmarkDocumentId.new("1", "2").call
  end
end
