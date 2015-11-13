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

  describe '#blacklight_config' do
    describe '.document_presenter_class' do
      subject { controller.blacklight_config.document_presenter_class }
      it { is_expected.to eq Dtu::DocumentPresenter }
    end
    describe '.solr_path' do
      subject { controller.blacklight_config.solr_path }
      it { is_expected.to eq 'toshokan' }
    end
    describe '.document_solr_path' do
      subject { controller.blacklight_config.document_solr_path }
      it { is_expected.to eq 'toshokan_document' }
    end
    describe 'default_solr_params' do
      subject { controller.blacklight_config.default_solr_params }
      it 'includes params for hit highlighting' do
        expect(subject).to include(
                               :hl => true,
                               'hl.snippets' => 3,
                               'hl.usePhraseHighlighter' => true,
                               'hl.fl' => 'title_ts, author_ts, journal_title_ts, conf_title_ts, abstract_ts, publisher_ts',
                               'hl.fragsize' => 300
                           )
      end
    end
    it 'enables highlighting for some fields' do
      ['author_ts', 'journal_title_ts', 'publisher_ts', 'abstract_ts'].each do |field|
        field_config = controller.blacklight_config.index_fields[field]
        expect(field_config.highlight).to eq true
      end
    end
    describe 'metrics_presenter_classes' do
      subject { controller.blacklight_config.metrics_presenter_classes }
      it { is_expected.to eq [Dtu::Metrics::AltmetricPresenter, Dtu::Metrics::IsiPresenter, Dtu::Metrics::DtuOrbitPresenter, Dtu::Metrics::PubmedPresenter] }
    end
  end

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

end
