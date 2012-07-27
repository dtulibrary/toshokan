require 'spec_helper'

describe TagsController do
  before do
    @user = login 
    @existing_pointer = SolrDocumentPointer.create(solr_id: 'a_solr_document_id')
  end

  describe "new" do

    it "should assign document pointer" do
      get :new, document_id: @existing_pointer.solr_id
      response.should be_successful
    end
  end

  describe "create" do

    it "adds the tag to the document that exists" do
      post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag'
      @existing_pointer.owner_tags_on(@user, :tags).map(&:name).should == ['the_tag']
      assigns[:document].should == @existing_pointer
    end

    it "should create and assign a document pointer that does not exists" do
      post :create, document_id: 'another_solr_document_id', tag_name: 'the_tag'
      @new_pointer = SolrDocumentPointer.find_by_solr_id('another_solr_document_id')
      @new_pointer.owner_tags_on(@user, :tags).map(&:name).should == ['the_tag']
    end

  end

end
