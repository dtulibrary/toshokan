require 'spec_helper'
require 'cancan/matchers'

describe TagsController do
  let!(:user) {
    login
  }

  let (:existing_bookmark) {
    Bookmark.create :document_id => 'a_solr_document_id'
  }

  let!(:ability) {
    ability = Object.new
    ability.extend CanCan::Ability
    controller.stub(:current_ability).and_return(ability)
    ability
  }

  describe "#manage" do
    context 'with ability to tag' do
      before do
      	ability.can :tag, Bookmark
      end

      it 'assigns the tags array' do
      	get :manage
        assigns(:tags).should == []
      end

      it 'renders the index template' do
      	get :manage
      	should render_template 'manage'
      end
    end

    context 'without ability to tag' do
      it 'returns an HTTP 404' do
        get :manage
        response.response_code.should == 404
      end
    end
  end

  describe "#new" do
    context 'with ability to tag' do
      before do
        ability.can :tag, Bookmark
      end

      it 'renders the new template' do
        get :new, document_id: existing_bookmark.document_id
        should render_template 'new'
      end
    end

    context 'without ability to tag' do
      it 'returns an HTTP 404' do
        get :new, document_id: existing_bookmark.document_id
        response.response_code.should == 404
      end
    end
  end

  describe "#create" do
    context 'with ability to tag' do
      before do
        ability.can :tag, Bookmark
      end
      
      context 'when bookmark exists' do
        it 'adds the tag to the document pointer' do
      	  post :create, document_id: existing_bookmark.document_id, tag_name: 'the_tag', return_url: root_path
      	  user.tags_for(existing_bookmark).map(&:name).should == ['the_tag']
        end
      end

      context 'when bookmark does not exist' do
        it 'creates the document pointer' do
          post :create, document_id: 'new-document-pointer', tag_name: 'the_tag', return_url: root_path
          user.tags_for('new-document-pointer').should_not be_nil
        end

        it 'adds the tag to the bookmark' do
          post :create, document_id: 'new-document-pointer', tag_name: 'the_tag', return_url: root_path
          user.tags_for('new-document-pointer').map(&:name).should == ['the_tag']
        end
      end

      context "on regular request" do
      	it 'redirects to the return_url' do
      	  post :create, document_id: existing_bookmark.document_id, tag_name: 'the_tag', return_url: root_path
      	  response.should redirect_to(root_path)
      	end
      end

      context "on ajax request" do
      	it 'redirects renders the javascript partial' do
      	  xhr :post, :create, document_id: existing_bookmark.document_id, tag_name: 'the_tag', return_url: root_path
      	  should render_template :partial => '_tag_refresh'
      	end
      end
    end

    context 'without ability to tag' do
      it 'returns an HTTP 404' do
        post :create, document_id: existing_bookmark.document_id, tag_name: 'the_tag', return_url: root_path
        response.response_code.should == 404
      end
    end
  end

  describe "management" do
    describe "#destroy" do
      context 'with ability to tag' do
        before do
          ability.can :tag, Bookmark
        end

        context 'when tag exists' do
      	  let (:tag) {
      	    post :create, document_id: existing_bookmark.document_id, tag_name: 'the_tag', return_url: root_path
      	    user.tags_for(existing_bookmark).first
      	  }
          
          it "deletes the tag from all of the user's tagged documents" do
      	    post :destroy, :id => tag.id, :return_url => root_path
      	    user.tags_for(existing_bookmark).should == []
          end

          it "does not delete the tag from other users' documents" do
      	    another_user = login
      	    post :create, :document_id => existing_bookmark.document_id, :tag_name => 'the_tag', :return_url => root_path
      	    login user
      	    post :destroy, :id => tag.id, :return_url => root_path
      	    another_user.tags_for(existing_bookmark).map(&:name).should == ['the_tag']
          end

      	  context "on regular request" do
      	    it 'redirects to the return_url' do
      	      post :destroy, :id => tag.id, :return_url => root_path
      	      should redirect_to root_path
      	    end
      	  end

      	  context "on ajax request" do
      	    it 'renders the javascript partial' do
      	      xhr :post, :destroy, :id => tag.id, :return_url => root_path
      	      should render_template :partial => "_tag_refresh"
      	    end
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
          ability.can :tag, Bookmark
        end

        context 'when tag exists' do
      	  let (:tag) {
      	    post :create, document_id: existing_bookmark.document_id, tag_name: 'the_tag', return_url: root_path
      	    user.tags_for(existing_bookmark).first
      	  }

          it 'assigns the tag' do
      	    get :edit, id: tag.id
      	    assigns(:tag).should == tag
          end

          it 'renders the edit view' do
      	    get :edit, id: tag.id
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
          ability.can :tag, Bookmark
        end

        context 'when tag exists' do
      	  let (:tag) {
      	    post :create, document_id: existing_bookmark.document_id, tag_name: 'the_tag', return_url: root_path
      	    user.tags_for(existing_bookmark).first
      	  }

          context 'with tag_name parameter' do
            it 'removes existing tag' do
      	      put :update, :id => tag.id, :tag_name => 'new_tag_name'
      	      user.tags_for(existing_bookmark).map(&:name).should_not include('the_tag')
            end

            it 'adds new tag' do
      	      put :update, :id => tag.id, :tag_name => 'new_tag_name'
      	      user.tags_for(existing_bookmark).map(&:name).should == ['new_tag_name']
            end
            
            it "updates tag for all the current user's documents" do
      	      another_bookmark = Bookmark.create :document_id => 'another_document_id'
      	      post :create, :document_id => another_bookmark.document_id, :tag_name => 'the_tag', :return_url => root_path
      	      put :update, :id => tag.id, :tag_name => 'new_tag_name'
      	      user.tags_for(existing_bookmark).map(&:name).should == ['new_tag_name']
      	      user.tags_for(another_bookmark).map(&:name).should == ['new_tag_name']
            end

            it "doesn't affect other users' tags" do
      	      another_user = login
      	      post :create, :document_id => existing_bookmark.document_id, :tag_name => 'the_tag', :return_url => root_path
      	      login user
      	      put :update, :id => tag.id, :tag_name => 'new_tag_name'
      	      user.tags_for(existing_bookmark).map(&:name).should == ['new_tag_name']
      	      another_user.tags_for(existing_bookmark).map(&:name).should == ['the_tag']
            end
          end

          context 'without tag_name parameter' do
            it 'returns an HTTP 404' do
      	      put :update, :id => tag.id
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
