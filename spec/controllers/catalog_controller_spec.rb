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
      let(:search_params) {{ :q => 'Kardiologiczny', 'f[author]'=>'Grabowski, Marcin' }}

      context "with access" do

        before do
          ability.can :search, :dtu
        end

        it "renders the document page" do
          get :show, params
          expect(response).to render_template('catalog/show')
        end

        it "injects last query into params without destroying relevant params" do
          get :index, search_params  # create previous search
          get :show, params
          expect(controller.params).to include(search_params)
          expect(controller.params[:action]).to eq 'show'
          expect(controller.params[:controller]).to eq 'catalog'
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

  describe "associating searches with users" do
    let(:user) { User.create }
    let(:other_user) { User.create }
    let(:repeated_params) { { "q" => "cymothoa exigua" } }
    let(:original_search) { user.searches.create(query_params:repeated_params.merge({"controller"=>"catalog", "action"=>"index"}) ) }
    before do
      original_search.save
    end
    it "only stores a search once per user" do
      expect(user.searches.count).to eq 1
      login user
      get :index, repeated_params
      expect(user.searches.count).to eq 1
      expect(user.searches.last).to eq original_search
    end
    it "does not steal searches from other users" do
      login other_user
      get :index, repeated_params
      expect(other_user.searches.count).to eq 1
      expect(user.searches.count).to eq 1
      # expect(other_user.searches.last).to be_a_new(Search)
      expect(other_user.searches.last).to_not eq original_search
      expect(other_user.searches.last.query_params).to eq original_search.query_params
    end
    it "doesn't save default 'empty' search" do
      login user
      user_searches_before = user.searches.all.load
      get :index, "utf8"=>"✓", "search_field"=>"all_fields", "locale"=>"en"
      expect(user.reload.searches).to eq user_searches_before
    end
    it "should reorder user searches to match user's actual search history (repeating a search puts it at the top fo your history)" do
      user.searches.create( query_params: {"q"=>"phronima sedentaria","controller"=>"catalog", "action"=>"index"} )
      user.searches.create( query_params: {"q"=>"pyrosome","controller"=>"catalog", "action"=>"index"} )
      expect(user.searches.order("updated_at DESC").first.query_params).to eq( {"q"=>"pyrosome","controller"=>"catalog", "action"=>"index"})
      login user
      get :index, repeated_params
      user.reload
      expect(user.searches.order("updated_at DESC").first).to eq( original_search )
    end
  end
end
