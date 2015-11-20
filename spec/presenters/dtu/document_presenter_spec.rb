require 'rails_helper'

describe Dtu::DocumentPresenter do
  let(:source_doc) { {'title_ts' => 'stored title_ts'} }
  let(:solr_response) { nil }
  let(:document) { SolrDocument.new(source_doc, solr_response) }
  let(:presenter) { described_class.new(document, CatalogController.new) }

  it 'sets the config to blacklight_config by default' do
    expect(presenter.instance_variable_get(:@configuration)).to eq presenter.instance_variable_get(:@view_context ).blacklight_config
  end
  it 'includes Dtu::DocumentPresenter::Metrics' do
    expect(described_class.included_modules).to include(Dtu::DocumentPresenter::Metrics)
  end
  describe 'render_document_index_label' do
    subject { presenter.render_document_index_label(:title_ts) }
    before do
      allow(document).to receive(:highlight_field).and_return(nil)
    end
    context 'when there are highlights available for the field (serch term has hits within the title)' do
      before do
        expect(document).to receive(:highlight_field).twice.with(:title_ts).and_return('highlighted title')
      end
      it 'returns a highlighted version of the title' do
        expect(subject).to eq 'highlighted title'
      end
    end
    context 'when no highlights are available' do
      it 'returns the stored value of the title' do
        expect(subject).to eq 'stored title_ts'
      end
    end
  end

  describe 'get_field_values' do
    let(:field) { 'publisher_ts' }
    let(:field_config) { CatalogController.blacklight_config.index_fields[field] }
    subject { presenter.get_field_values(field, field_config) }
    context 'when highlights are available' do
      before do
        allow(document).to receive(:has_highlight_field?).with('publisher_ts').and_return(true)
        allow(document).to receive(:highlight_field).with('publisher_ts').and_return(['highlight1'])
      end
      it 'returns highlights when they are available' do
        expect(subject).to eq ["highlight1"]
      end
    end
    context 'when highlights are NOT available' do
      before do
        allow(document).to receive(:has_highlight_field?).with('publisher_ts').and_return(false)
        expect(document).to receive(:fetch).with('publisher_ts', field_config.default).and_return('stored field value')
      end
      it 'returns the stored value of the field' do
        expect(subject).to eq 'stored field value'
      end
    end
  end
end