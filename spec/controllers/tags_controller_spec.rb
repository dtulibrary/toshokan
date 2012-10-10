require 'spec_helper'

describe TagsController do
  before do
    @user = login 
    @existing_pointer = SolrDocumentPointer.create(solr_id: 'a_solr_document_id')
  end

  describe "index" do
    it "assigns the tags array" do
      get :index
      assigns(:tags).should_not be_nil
      response.should be_successful
    end
  end

  describe "new" do
    it "is successful" do
      get :new, document_id: @existing_pointer.solr_id
      response.should be_successful
    end
  end

  describe "create" do
    it "adds the tag to the document pointer that exists" do
      post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
      @existing_pointer.owner_tags_on(@user, :tags).map(&:name).should == ['the_tag']
      response.should redirect_to(root_path)
    end

    it "creates and assigns a document pointer that does not exists and add the tag" do
      post :create, document_id: 'another_solr_document_id', tag_name: 'the_tag', return_url: root_path
      @new_pointer = SolrDocumentPointer.find_by_solr_id('another_solr_document_id')
      @new_pointer.owner_tags_on(@user, :tags).map(&:name).should == ['the_tag']
    end

    it "redirects to the return_url" do
      post :create, document_id: 'another_solr_document_id', tag_name: 'the_tag', return_url: root_path
      response.should redirect_to(root_path)
    end
  end

  describe "destroy" do
    before(:each) do
      post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
      @tag = @existing_pointer.owner_tags_on(@user, :tags).first
    end

    it "deletes the tag that exists on a document" do
      post :destroy, document_id: @existing_pointer.solr_id, id: @tag.id, return_url: root_path
      @existing_pointer.owner_tags_on(@user, :tags).map(&:name).should == []
    end

    it "redirects to the return_url" do
      post :destroy, document_id: @existing_pointer.solr_id, id: @tag.id, return_url: root_path
      response.should redirect_to(root_path)
    end
  end

  describe "management" do
    describe "destroy" do
      it "deletes the tag from all tagged documents" do
        post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
        @tag = @existing_pointer.owner_tags_on(@user, :tags).first
        post :create, document_id: 'another_solr_document_id', tag_name: 'the_tag', return_url: root_path
        @another_pointer = SolrDocumentPointer.find_by_solr_id('another_solr_document_id')

        post :destroy, id: @tag.id, return_url: root_path
        @existing_pointer.owner_tags_on(@user, :tags).map(&:name).should == []
        @another_pointer.owner_tags_on(@user, :tags).map(&:name).should == []
      end

      it "only deletes tags for the current_user" do
        @another_user = login
        post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
        login(@user)
        post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
        @tag = @existing_pointer.owner_tags_on(@user, :tags).first
        post :destroy, id: @tag.id, return_url: root_path

        @existing_pointer.owner_tags_on(@user, :tags).map(&:name).should == []
        @existing_pointer.owner_tags_on(@another_user, :tags).map(&:name).should == ['the_tag']
      end
    end

    describe "edit" do
      it "assigns the tag" do
        post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
        @tag = @existing_pointer.owner_tags_on(@user, :tags).first
        get :edit, id: @tag.id

        assigns(:tag).should_not be_nil
        response.should be_successful
      end
    end

    describe "update" do
      it "renames the tag on all tagged documents" do
        post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
        @tag = @existing_pointer.owner_tags_on(@user, :tags).first
        post :create, document_id: 'another_solr_document_id', tag_name: 'the_tag', return_url: root_path
        @another_pointer = SolrDocumentPointer.find_by_solr_id('another_solr_document_id')

        put :update, id: @tag.id, tag_name: 'the_renamed_tag'
        @existing_pointer.owner_tags_on(@user, :tags).map(&:name).should == ['the_renamed_tag']
        @another_pointer.owner_tags_on(@user, :tags).map(&:name).should == ['the_renamed_tag'] 
      end

      it "only renames tags for the current_user" do
        @another_user = login
        post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
        login(@user)
        post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
        @tag = @existing_pointer.owner_tags_on(@user, :tags).first
        put :update, id: @tag.id, tag_name: 'the_renamed_tag'

        @existing_pointer.owner_tags_on(@user, :tags).map(&:name).should == ['the_renamed_tag']
        @existing_pointer.owner_tags_on(@another_user, :tags).map(&:name).should == ['the_tag']
      end
    end
  end
end
