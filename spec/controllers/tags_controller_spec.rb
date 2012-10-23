require 'spec_helper'
require 'cancan/matchers'

describe TagsController do
  before do
    @user = login
    @existing_pointer = SolrDocumentPointer.create :solr_id => 'a_solr_document_id'
    @ability = Object.new
    @ability.extend CanCan::Ability
    controller.stub(:current_ability).and_return(@ability)
  end

  describe "#index" do
    context 'with ability to tag' do
      before do
        @ability.can :tag, SolrDocument
      end

      it 'assigns the tags array' do
        get :index
        assigns(:tags).should == []
      end

      it 'renders the index template' do
        get :index
        should render_template 'index'
      end
    end

    context 'without ability to tag' do
      it 'returns an HTTP 404' do
        get :index
        response.response_code.should == 404
      end
    end
  end

  describe "#new" do
    context 'with ability to tag' do
      before do
        @ability.can :tag, SolrDocument
      end

      it 'renders the new template' do
        get :new, document_id: @existing_pointer.solr_id
        should render_template 'new'
      end
    end

    context 'without ability to tag' do
      it 'returns an HTTP 404' do
        get :new, document_id: @existing_pointer.solr_id
        response.response_code.should == 404
      end
    end
  end

  describe "#create" do
    context 'with ability to tag' do
      before do
        @ability.can :tag, SolrDocument
      end
      
      context 'when document pointer exists' do
        it 'adds the tag to the document pointer' do
          post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
          @existing_pointer.owner_tags_on(@user, :tags).map(&:name).should == ['the_tag']
        end
      end

      context 'when document pointer does not exist' do
        it 'creates the document pointer' do
          post :create, document_id: 'new-document-pointer', tag_name: 'the_tag', return_url: root_path
          SolrDocumentPointer.find_by_solr_id('new-document-pointer').should_not be_nil
        end

        it 'adds the tag to the document pointer' do
          post :create, document_id: 'new-document-pointer', tag_name: 'the_tag', return_url: root_path
          SolrDocumentPointer.find_by_solr_id('new-document-pointer').owner_tags_on(@user, :tags).map(&:name).should == ['the_tag']
        end
      end

      it 'redirects to the return_url' do
        post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
        response.should redirect_to(root_path)
      end
    end

    context 'without ability to tag' do
      it 'returns an HTTP 404' do
        post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
        response.response_code.should == 404
      end
    end
  end

  describe "management" do
    describe "#destroy" do
      context 'with ability to tag' do
        before do
          @ability.can :tag, SolrDocument
        end

        context 'when tag exists' do
          before do
            post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
            @tag = @existing_pointer.owner_tags_on(@user, :tags).first
          end
          
          it "deletes the tag from all of the user's tagged documents" do
            post :destroy, :id => @tag.id, :return_url => root_path
            @existing_pointer.owner_tags_on(@user, :tags).should == []
          end

          it "does not delete the tag from other users' documents" do
            @another_user = login
            post :create, :document_id => @existing_pointer.solr_id, :tag_name => 'the_tag', :return_url => root_path
            login @user
            @tag = @existing_pointer.owner_tags_on(@user, :tags).first
            post :destroy, :id => @tag.id, :return_url => root_path
            @existing_pointer.owner_tags_on(@another_user, :tags).map(&:name).should == ['the_tag']
          end

          it 'redirects to the return_url' do
            post :destroy, :id => @tag.id, :return_url => root_path
            should redirect_to root_path
          end
        end

        context 'when tag does not exist' do
          it 'returns an HTTP 404' do
            post :destroy, :id => 12345, :return_url => root_path
            response.response_code.should == 404
          end
        end
      end

      context 'without ability to tag' do
        it 'returns an HTTP 404' do
          post :destroy, :id => 12345, :return_url => root_path
          response.response_code.should == 404
        end
      end
    end

    describe "#edit" do
      context 'with ability to tag' do
        before do
          @ability.can :tag, SolrDocument
        end

        context 'when tag exists' do
          before do
            post :create, document_id: @existing_pointer.solr_id, tag_name: 'the_tag', return_url: root_path
            @tag = @existing_pointer.owner_tags_on(@user, :tags).first
          end

          it 'assigns the tag' do
            get :edit, id: @tag.id
            assigns(:tag).should == @tag
          end

          it 'renders the edit view' do
            get :edit, id: @tag.id
            should render_template 'edit'
          end
        end

        context 'when tag does not exist' do
          it 'returns an HTTP 404' do
            get :edit, :id => '12345'
            response.response_code.should == 404
          end
        end

      end

      context 'without ability to tag' do
        it 'returns an HTTP 404' do
          get :edit, :id => '12345'
          response.response_code.should == 404
        end
      end
    end

    describe "#update" do
      context 'with ability to tag' do
        before do
          @ability.can :tag, SolrDocument
        end

        context 'when tag exists' do
          before do
            post :create, :document_id => @existing_pointer.solr_id, :tag_name => 'the_tag', :return_url => root_path
            @tag = @existing_pointer.owner_tags_on(@user, :tags).first
          end

          context 'with tag_name parameter' do
            it 'removes existing tag' do
              put :update, :id => @tag.id, :tag_name => 'new_tag_name'
              @existing_pointer.owner_tags_on(@user, :tags).map(&:name).include?('the_tag').should be_false
            end

            it 'adds new tag' do
              put :update, :id => @tag.id, :tag_name => 'new_tag_name'
              @existing_pointer.owner_tags_on(@user, :tags).map(&:name).should == ['new_tag_name']
            end
            
            it "updates tag for all the current user's documents" do
              another_pointer = SolrDocumentPointer.create :solr_id => 'another_document_id'
              post :create, :document_id => another_pointer.solr_id, :tag_name => 'the_tag', :return_url => root_path
              put :update, :id => @tag.id, :tag_name => 'new_tag_name'
              @existing_pointer.owner_tags_on(@user, :tags).map(&:name).should == ['new_tag_name']
              another_pointer.owner_tags_on(@user, :tags).map(&:name).should == ['new_tag_name']
            end

            it "doesn't affect other users' tags" do
              @another_user = login
              post :create, :document_id => @existing_pointer.solr_id, :tag_name => 'the_tag', :return_url => root_path
              login @user
              put :update, :id => @tag.id, :tag_name => 'new_tag_name'
              @existing_pointer.owner_tags_on(@another_user, :tags).map(&:name).should == ['the_tag']
            end
          end

          context 'without tag_name parameter' do
            it 'returns an HTTP 404' do
              put :update, :id => @tag.id
              response.response_code.should == 404
            end
          end
        end

        context 'when tag does not exist' do
          it 'returns an HTTP 404' do
            put :update, :id => '12345'
            response.response_code.should == 404
          end
        end
      end

      context 'without ability to tag' do
        it 'returns an HTTP 404' do
          put :update, :id => '12345'
          response.response_code.should == 404
        end
      end
    end
  end
end
