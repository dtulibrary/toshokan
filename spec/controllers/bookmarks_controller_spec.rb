require 'rails_helper'
require 'cancan/matchers'

describe BookmarksController do
  let!(:user) {
    login
  }
  let!(:another_user) {
    login
  }

  let(:document) {
    SolrDocument.new("cluster_id_ss"=>"2842957")
  }

  let (:existing_bookmark) {
    # user.bookmarks.create({:document_id => document.id, document_type:"SolrDocument"})
    user.bookmarks.create({document:document})
  }

  let!(:ability) {
    ability = Object.new
    ability.extend CanCan::Ability
    allow(controller).to receive(:current_ability).and_return(ability)
    ability
  }


  describe "#update" do
    context 'with ability to tag' do
      before do
        ability.can :tag, Bookmark
        login user
      end

      context 'when bookmark does not exist' do
        it "adds the bookmark to the user's bookmarks" do
          expect( user.bookmarks ).to be_empty
          expect( user.existing_bookmark_for(document) ).to be_nil
          post :update, :id => document.id, :return_url => root_path
          expect( user.bookmarks.count ).to eq 1
          expect( user.existing_bookmark_for(document) ).to eq user.bookmarks.first
        end

        it "doesn't affect other users' bookmarks" do
          login user
          put :update, :id => document.id, :return_url => root_path
          expect( another_user.existing_bookmark_for(document) ).to be_nil
        end
      end

      context 'when bookmark exists' do
        before do
          existing_bookmark.save
        end
        it "returns the bookmark" do
          login user
          put :update, :id => document.id, :return_url => root_path
          expect( user.existing_bookmark_for(document) ).to eq existing_bookmark
        end
      end
    end

    context 'without ability to tag' do
      it 'redirects to Authentication Required' do
        put :update, :id => '12345'
        expect(response).to be_redirect
      end
    end
  end

  describe "#destroy" do
    context 'with ability to tag' do
      before do
        ability.can :tag, Bookmark
        login user
      end

      context 'when bookmark exists' do
        before do
          existing_bookmark.save
          allow(controller).to receive(:get_solr_response_for_doc_id).and_return([nil,document])
        end

        it "deletes the bookmark from the user's bookmarks" do
          expect( user.bookmarks ).to include(existing_bookmark)
          post :destroy, :id => document.id, :return_url => root_path
          expect( user.reload.bookmarks ).to_not include(existing_bookmark)
          expect( user.existing_bookmark_for(document) ).to be_nil
        end

        it "does not delete the tag from other users' documents" do
          other_bookmark = another_user.bookmarks.create(document:document)
          post :destroy, :id => document.id, :return_url => root_path
          expect( another_user.existing_bookmark_for(document) ).to eq other_bookmark
        end

        context "on regular request" do
          it 'redirects to the return_url' do
            post :destroy, :id => existing_bookmark.id, :return_url => root_path
            expect(response).to redirect_to root_path
          end
        end

        context "on ajax request" do
          it 'renders the javascript partial' do
            xhr :post, :destroy, :id => document.id, :return_url => root_path
            expect(response).to render_template :partial => "_tag_refresh"
          end
        end
      end

      context 'when bookmark does not exist' do
        it 'is not found' do
          post :destroy, :id => document.id, :return_url => root_path
          expect(response).to be_not_found
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
end
