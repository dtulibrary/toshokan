require 'rails_helper'

describe Dtu::Metrics::IsiPresenter, type: :view do
  let(:document) { SolrDocument.new }
  let(:presenter) { described_class.new(document, view, {}) }

  describe '#should_render?' do
    subject { presenter.should_render? }

    context 'when document has isi source' do
      before do
        document['source_ss'] = ['isi']
      end

      context 'when document has isi url' do
        before do
          document['isi_url_ssf'] = ['some-isi-url']
        end

        it 'returns true' do
          expect( subject ).to eq true
        end
      end

      context 'when document has no isi url' do
        it 'returns false' do
          expect( subject ).to eq false
        end
      end
    end

    context 'when document has no isi source' do
      it 'returns false' do
        expect( subject ).to eq false
      end
    end
  end

  describe '#link_to_isi' do
    subject { presenter.link_to_isi }

    context 'when document has isi source' do
      before do
        document['source_ss'] = ['isi']
      end

      context 'when document has isi url' do
        before do
          document['isi_url_ssf'] = ['some-isi-url']
        end

        it 'renders the isi link' do
          expect( subject ).to have_css('.isi-backlink')
        end
      end

      context 'when document has no isi url' do
        it 'does not render the isi link' do
          expect( subject ).to_not have_css('.isi-backlink')
        end
      end
    end

    context 'when document has no isi source' do
      it 'does not render the isi link' do
        expect( subject ).to_not have_css('.isi-backlink')
      end
    end
  end
end
