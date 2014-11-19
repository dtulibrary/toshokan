# -*- encoding: utf-8 -*-
require 'rails_helper'
require 'cancan/matchers'

describe CatalogController do

  let!(:ability) {
    ability = Object.new
    ability.extend CanCan::Ability
    allow(controller).to receive(:current_ability).and_return(ability)
    ability
  }

  describe "#index" do

    let!(:user) {
      login
    }

    context 'with tag parameters' do
      let(:params) {
        { :t => { '✩All' => '✓' } }
      }

      context 'with ability to tag' do
        before do
          ability.can :tag, Bookmark
        end
        it 'renders the catalog' do
          get :index, params
          expect(response).to render_template('catalog/index')
        end
      end

      context 'without ability to tag' do
        it 'redirects to Authentication Required' do
          get :index, params
          expect(response).to redirect_to authentication_required_url(:url => catalog_index_url(params))
        end
      end
    end

  end

  describe "#show" do

    context "when the document exists" do

      let(:params) {{ :id => "183644425" }}

      context "with access" do

        before do
          ability.can :search, :dtu
        end

        it "renders the document page" do
          get :show, params
          expect(response).to render_template('catalog/show')
        end
      end

      context "without access" do

        before do
          ability.can :search, :public
        end

        it "redirects to dtu login for anonymous users" do
          get :show, params
          expect(response).to redirect_to new_user_session_path(:url => catalog_url(params), :only_dtu => true)
        end

        it "redirects to authentication required for public users" do
          user = login
          expect(user.public?).to be_truthy
          get :show, params
          expect(response).to redirect_to authentication_required_catalog_url(:url => catalog_url(params))
        end
      end
    end

    context "when document does not exist" do

      it "is not found" do
        params = {:id => "123456789"}
        get :show, params
        expect(response).to be_not_found
      end
    end
  end
end
