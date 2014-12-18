require 'rails_helper'

describe PubmedHelper do
  
  describe '#render_link_to_pubmed?' do
    before do
      @document = SolrDocument.new
    end

    context 'when document has pubmed source' do
      before do
        @document['source_ss'] = ['pubmed']
      end

      context 'when document has pubmed url' do
        before do
          @document['pubmed_url_ssf'] = 'some-pubmed-url'
        end

        it 'returns true' do
          expect( render_link_to_pubmed? @document ).to be_truthy
        end
      end

      context 'when document has no pubmed url' do
        it 'returns false' do
          expect( render_link_to_pubmed? @document ).to be_falsey
        end
      end
    end

    context 'when document has no pubmed source' do
      it 'returns false' do
        expect( render_link_to_pubmed? @document ).to be_falsey
      end
    end
  end

  describe '#link_to_pubmed' do
    before do
      @document = SolrDocument.new
    end

    context 'when document has pubmed source' do
      before do
        @document['source_ss'] = ['pubmed']
      end

      context 'when document has pubmed url' do
        before do
          @document['pubmed_url_ssf'] = ['some-pubmed-url']
        end

        it 'renders the pubmed link' do
          expect( link_to_pubmed @document ).to have_css('.pubmed-backlink')
        end
      end

      context 'when document has no pubmed url' do
        it 'does not render the pubmed link' do
          expect( link_to_pubmed @document ).to_not have_css('.pubmed-backlink')
        end
      end
    end

    context 'when document has no pubmed source' do
      it 'does not render the pubmed link' do
        expect( link_to_pubmed @document ).to_not have_css('.pubmed-backlink')
      end
    end
  end

end
