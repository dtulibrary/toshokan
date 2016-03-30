require 'rails_helper'

describe PubmedHelper do
  let(:document) { SolrDocument.new }
  let(:valid_pubmed_url) { 'http://www.ncbi.nlm.nih.gov/pubmed/23089997?otool=idktudlib' }

  describe '#render_link_to_pubmed?' do
    subject { render_link_to_pubmed?(document) }
    context 'when document has pubmed source' do
      before do
        document['source_ss'] = ['pubmed']
        document['backlink_ss'] = [ backlink ]
      end

      context 'when document has pubmed url' do
        let(:backlink) { valid_pubmed_url }
        it { should be true }
      end

      context 'when document has no pubmed url' do
        let(:backlink) { 'someotherlink.com' }
        it { should be false }
      end
    end

    context 'when document has no pubmed source' do
      it { should be false }
    end
  end

  describe '#link_to_pubmed' do
    subject {  link_to_pubmed(document) }
    context 'when document has pubmed source' do
      before do
        document['source_ss'] = ['pubmed']
        document['backlink_ss'] = [ backlink ]
      end

      context 'when document has pubmed url' do
        let(:backlink) { valid_pubmed_url }
        it 'renders the pubmed link' do
          expect(subject).to have_css('.pubmed-backlink')
        end
      end

      context 'when document has no pubmed url' do
        let(:backlink) { 'someotherlink.com' }
        it 'does not render the pubmed link' do
          expect(subject).to_not have_css('.pubmed-backlink')
        end
      end
    end

    context 'when document has no pubmed source' do
      it 'does not render the pubmed link' do
        expect(subject).to_not have_css('.pubmed-backlink')
      end
    end
  end

end
