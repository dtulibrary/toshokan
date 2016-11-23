require 'rails_helper'
require 'cancan/matchers'

describe TagsController do
  let!(:user) {
    login
  }

  let (:document) {
    SolrDocument.new(SolrDocument.unique_key => '2842957')
  }

  let (:existing_bookmark) {
    user.bookmark document
  }

  let (:another_document) {
    SolrDocument.new(SolrDocument.unique_key => '1234567')
  }

  let!(:ability) {
    ability = Object.new
    ability.extend CanCan::Ability
    allow(controller).to receive(:current_ability).and_return(ability)
    ability
  }

  describe "#manage" do
    context 'with ability to tag' do
      before do
        ability.can :tag, Bookmark
      end

      it 'assigns the tags array' do
        get :manage
        expect( assigns(:tags) ).to eq []
      end

      it 'renders the index template' do
        get :manage
        expect(response).to render_template 'manage'
      end
    end

    context 'without ability to tag' do
      it 'redirects to Authentication Required' do
        get :manage
        expect(response).to redirect_to authentication_required_url(:url => manage_tags_url)
      end
    end
  end

  describe "#new" do
    context 'with ability to tag' do
      before do
        ability.can :tag, Bookmark
      end

      it 'renders the new template' do
        get :new, document_id: document[SolrDocument.unique_key]
        expect(response).to render_template 'new'
      end
    end

    context 'without ability to tag' do
      it 'redirects to Authentication Required' do
        get :new, document_id: document[SolrDocument.unique_key]
        expect(response).to redirect_to authentication_required_url(:url => new_document_tag_url)
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
          post :create, document_id: document[SolrDocument.unique_key], tag_name: 'the_tag', return_url: root_path
          expect(user.existing_tags_for(document).map(&:name)).to eq ['the_tag']
        end
      end

      context 'when bookmark does not exist' do
        it 'creates the document pointer' do
          post :create, document_id: another_document[SolrDocument.unique_key], tag_name: 'the_tag', return_url: root_path
          expect(user.existing_tags_for(another_document)).to_not be_nil
        end

        it 'adds the tag to the bookmark' do
          post :create, document_id: another_document[SolrDocument.unique_key], tag_name: 'the_tag', return_url: root_path
          expect(user.existing_tags_for(another_document).map(&:name)).to eq ['the_tag']
        end
      end

      context "on regular request" do
        it 'redirects to the return_url' do
          post :create, document_id: document[SolrDocument.unique_key], tag_name: 'the_tag', return_url: root_path
          expect(response).to redirect_to(root_path)
        end
      end

      context "on ajax request" do
        it 'redirects renders the javascript partial' do
          xhr :post, :create, document_id: document[SolrDocument.unique_key], tag_name: 'the_tag', return_url: root_path
          expect(response).to render_template :partial => '_tag_refresh'
        end
      end
    end

    context 'without ability to tag' do
      it 'redirects to Authentication Required' do
        post :create, document_id: document[SolrDocument.unique_key], tag_name: 'the_tag', return_url: root_path
        expect(response).to be_redirect
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
            post :create, document_id: document[SolrDocument.unique_key], tag_name: 'the_tag', return_url: root_path
            user.existing_tags_for(document).first
          }

          it "deletes the tag from all of the user's tagged documents" do
            post :destroy, :id => tag.id, :return_url => root_path
            expect(user.existing_tags_for(document)).to eq []
          end

          it "does not delete the tag from other users' documents" do
            another_user = login
            post :create, document_id: document[SolrDocument.unique_key], tag_name: 'the_tag', return_url: root_path
            login user
            post :destroy, id: tag.id, return_url: root_path
            expect(another_user.existing_tags_for(document).map(&:name)).to eq ['the_tag']
          end

          context "on regular request" do
            it 'redirects to the return_url' do
              post :destroy, id: tag.id, return_url: root_path
              expect(response).to redirect_to root_path
            end
          end

          context "on ajax request" do
            it 'renders the javascript partial' do
              xhr :post, :destroy, id: tag.id, return_url: root_path
              expect(response).to render_template partial: "_tag_refresh"
            end
          end
        end

        context 'when tag does not exist' do
          it 'raises a routing error' do
            expect {
              post :destroy, id: 12345, return_url: root_path
            }.to raise_error(ActionController::RoutingError)
          end
        end
      end

      context 'without ability to tag' do
        it 'redirects to Authentication Required' do
          post :destroy, :id => 12345, :return_url => root_path
          expect(response).to be_redirect
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
            post :create, document_id: document[SolrDocument.unique_key], tag_name: 'the_tag', return_url: root_path
            user.existing_tags_for(document).first
          }

          it 'assigns the tag' do
            get :edit, id: tag.id
            expect(assigns(:tag)).to eq tag
          end

          it 'renders the edit view' do
            get :edit, id: tag.id
            expect(response).to render_template 'edit'
          end
        end

        context 'when tag does not exist' do
          it 'raises a routing error' do
            expect {
              get :edit, id: '12345'
            }.to raise_error(ActionController::RoutingError)
          end
        end

      end

      context 'without ability to tag' do
        it 'redirects to Authentication Required' do
          get :edit, id: '12345'
          expect(response).to be_redirect
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
            post :create, document_id: document[SolrDocument.unique_key], tag_name: 'the_tag', return_url: root_path
            user.existing_tags_for(document).first
          }

          context 'with tag_name parameter' do
            it 'removes existing tag' do
              put :update, id: tag.id, tag_name: 'new_tag_name'
              expect(user.existing_tags_for(document).map(&:name)).to_not include('the_tag')
            end

            it 'adds new tag' do
              put :update, id: tag.id, tag_name: 'new_tag_name'
              expect(user.existing_tags_for(document).map(&:name)).to eq ['new_tag_name']
            end

            it "updates tag for all the current user's documents" do
              user.bookmark(another_document)
              post :create, document_id: another_document[SolrDocument.unique_key], tag_name: 'the_tag', return_url: root_path
              put :update, id: tag.id, tag_name: 'new_tag_name'
              expect(user.existing_tags_for(document).map(&:name)).to eq ['new_tag_name']
              expect(user.existing_tags_for(another_document).map(&:name)).to eq ['new_tag_name']
            end

            it "doesn't affect other users' tags" do
              another_user = login
              post :create, document_id: document[SolrDocument.unique_key], tag_name: 'the_tag', return_url: root_path
              login user
              put :update, id: tag.id, tag_name: 'new_tag_name'
              expect(user.existing_tags_for(document).map(&:name)).to eq ['new_tag_name']
              expect(another_user.existing_tags_for(document).map(&:name)).to eq ['the_tag']
            end
          end

          context 'without tag_name parameter' do
            it 'raises a routing error' do
              expect {
                put :update, id: tag.id
              }.to raise_error(ActionController::RoutingError)
            end
          end
        end

        context 'when tag does not exist' do
          it 'raises a routing error' do
            expect {
              put :update, id: '12345'
            }.to raise_error(ActionController::RoutingError)
          end
        end
      end

      context 'without ability to tag' do
        it 'redirects to Authentication Required' do
          put :update, id: '12345'
          expect(response).to be_redirect
        end
      end
    end
  end
end
