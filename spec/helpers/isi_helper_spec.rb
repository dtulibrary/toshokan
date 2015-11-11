require 'rails_helper'

describe IsiHelper do
  
  describe '#should_render_link_to_isi?' do
    before do
      @document = SolrDocument.new
    end

    context 'when document has isi source' do
      before do
        @document['source_ss'] = ['isi']
      end

      context 'when document has isi url' do
        before do
          @document['isi_url_ssf'] = ['some-isi-url']
        end

        it 'returns true' do
          expect( should_render_link_to_isi? @document ).to be_truthy
        end
      end

      context 'when document has no isi url' do
        it 'returns false' do
          expect( should_render_link_to_isi? @document ).to be_falsey
        end
      end
    end

    context 'when document has no isi source' do
      it 'returns false' do
        expect( should_render_link_to_isi? @document ).to be_falsey
      end
    end
  end

  describe '#link_to_isi' do
    before do
      @document = SolrDocument.new
    end

    context 'when document has isi source' do
      before do
        @document['source_ss'] = ['isi']
      end

      context 'when document has isi url' do
        before do
          @document['isi_url_ssf'] = ['some-isi-url']
        end

        it 'renders the isi link' do
          expect( link_to_isi @document ).to have_css('.isi-backlink')
        end
      end

      context 'when document has no isi url' do
        it 'does not render the isi link' do
          expect( link_to_isi @document ).to_not have_css('.isi-backlink')
        end
      end
    end

    context 'when document has no isi source' do
      it 'does not render the isi link' do
        expect( link_to_isi @document ).to_not have_css('.isi-backlink')
      end
    end
  end
end
