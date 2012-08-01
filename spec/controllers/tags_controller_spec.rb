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

    it "should add the tag to the document that exists" do
      post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
      @existing_pointer.owner_tags_on(@user, :tags).map(&:name).should == ['the_tag']
      assigns[:document].should == @existing_pointer
      response.should redirect_to(root_path)
    end

    it "should create and assign a document pointer that does not exists and add the tag" do
      post :create, document_id: 'another_solr_document_id', tag_name: 'the_tag', return_url: root_path
      @new_pointer = SolrDocumentPointer.find_by_solr_id('another_solr_document_id')
      @new_pointer.owner_tags_on(@user, :tags).map(&:name).should == ['the_tag']
    end

    it "should redirect to return_url" do
      post :create, document_id: 'another_solr_document_id', tag_name: 'the_tag', return_url: root_path
      response.should redirect_to(root_path)
    end
  end

  describe "destroy" do
    before(:each) do
      post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
      @tag = @existing_pointer.owner_tags_on(@user, :tags).first
    end

    it "should delete the tag that exists" do
      post :destroy, document_id: @existing_pointer.solr_id, id: @tag.id, return_url: root_path
      @existing_pointer.owner_tags_on(@user, :tags).map(&:name).should == []
    end

    it "should redirect to return_url" do
      post :destroy, document_id: @existing_pointer.solr_id, id: @tag.id, return_url: root_path
      response.should redirect_to(root_path)
    end

  end

end
