# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'cancan/matchers'

describe CatalogController do
  let!(:user) {
    login
  }

  let!(:ability) {
    ability = Object.new
    ability.extend CanCan::Ability
    controller.stub(:current_ability).and_return(ability)
    ability
  }

  describe "#index" do

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
          response.should render_template('catalog/index')
        end
      end

      context 'without ability to tag' do
        it 'redirects to Authentication Required' do
          get :index, params
          response.should redirect_to authentication_required_url(:url => catalog_index_url(params))
        end
      end
    end

  end

end
