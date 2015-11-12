require 'rails_helper'

describe Dtu::Metrics::PubmedPresenter, type: :view do
  let(:document) { SolrDocument.new }
  let(:document_with_pubmed_source) { SolrDocument.new('source_ss'=>['pubmed']) }

  let(:presenter) { described_class.new(document, view, {}) }

  describe '#should_render?' do
    subject { presenter.should_render? }
    context 'when document has pubmed source' do
      let(:document) { document_with_pubmed_source }

      context 'when document has pubmed url' do
        before do
          document['pubmed_url_ssf'] = 'some-pubmed-url'
        end
        it 'returns true' do
          expect( subject ).to eq true
        end
      end

      context 'when document has no pubmed url' do
        it 'returns false' do
          expect( subject ).to eq false
        end
      end
    end

    context 'when document has no pubmed source' do
      it 'returns false' do
        expect( subject ).to eq false
      end
    end
  end

  describe '#link_to_pubmed' do
    subject { presenter.link_to_pubmed }

    context 'when document has pubmed source' do
      let(:document) { document_with_pubmed_source }

      context 'when document has pubmed url' do
        before do
          document['pubmed_url_ssf'] = ['some-pubmed-url']
        end

        it 'renders the pubmed link' do
          expect( subject ).to have_css('.pubmed-backlink')
        end
      end

      context 'when document has no pubmed url' do
        it 'does not render the pubmed link' do
          expect( subject ).to_not have_css('.pubmed-backlink')
        end
      end
    end

    context 'when document has no pubmed source' do
      it 'does not render the pubmed link' do
        expect( subject ).to_not have_css('.pubmed-backlink')
      end
    end
  end

end
