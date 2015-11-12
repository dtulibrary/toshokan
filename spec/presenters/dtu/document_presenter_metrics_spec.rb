require 'rails_helper'

describe Dtu::DocumentPresenter::Metrics, type: :view do
  let(:described_class) { Dtu::DocumentPresenter }
  let(:source_doc) { {} }
  let(:solr_response) { nil }
  let(:document) { SolrDocument.new(source_doc, solr_response) }
  let(:request_context) { view }
  let(:presenter) { described_class.new(document, request_context, CatalogController.blacklight_config) }
  let(:rendered) { Capybara::Node::Simple.new(subject) }
  describe 'metrics_presenters' do
    subject { presenter.metrics_presenters }
    it 'returns instances of all the presenter classes' do
      expect(subject.count).to eq(4)
      [Dtu::Metrics::AltmetricPresenter, Dtu::Metrics::IsiPresenter, Dtu::Metrics::DtuOrbitPresenter, Dtu::Metrics::PubmedPresenter].each do |presenter_class|
        expect(subject.any? {|presenter| presenter.instance_of?(presenter_class) }).to eq true
      end
    end
  end
  describe 'render_metrics' do
    let(:render_me1) { double(:should_render? => true, render: 'Render Me')}
    let(:render_me2) { double(:should_render? => true, render: 'Me too')}
    let(:do_not_render_me) { double(:should_render? => false)}
    subject { presenter.render_metrics }
    it 'renders a div for the output from each metric, skipping the ones that dont want to be rendered' do
      allow(presenter).to receive(:metrics_presenters).and_return([render_me1, do_not_render_me ,render_me2])
      expect(do_not_render_me).to_not receive(:render)
      expect(rendered.find_css('div.metric').count).to eq 2
      expect(subject).to have_selector('div.metric', text:'Render Me')
      expect(subject).to have_selector('div.metric', text:'Me too')
    end
  end

end