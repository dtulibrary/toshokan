require 'rails_helper'

describe ScopusHelper do
  let(:document) { SolrDocument.new }
  let(:valid_scopus_url) { 'http://www.scopus.com/inward/record.url?eid=2-s2.0-84911091105&partnerID=HzOxMe3b' }

  let(:invalid_isi_url) { 'http://somethingelse.com/cps/openurl/service?url_ver=Z39.88-2004&rft_id=info%3Aut%2F000366928800014' }

  describe '#render_link_to_scopus?' do
    subject { render_link_to_scopus?(document) }

    context 'when document has scopus source' do
      before do
        document['source_ss'] = ['scopus']
        document['backlink_ss'] = [ backlink ]
      end

      context 'when document has scopus url' do
        let(:backlink) { valid_scopus_url }
        it { should be true }
      end

      context "when document has invalid scopus url" do
        let(:backlink) { invalid_isi_url }
        it { should be false }
      end

      context 'when document has no scopus url' do
        let(:backlink) { '' }
        it { should be false }
      end
    end

    context 'when document has no scopus source' do
      it { should be false }
    end
  end

  describe '#link_to_scopus' do
    subject{ link_to_scopus(document) }
    context 'when document has scopus source' do
      before do
        document['source_ss'] = ['scopus']
      end

      context 'when document has scopus url' do
        before do
          document['backlink_ss'] = [ valid_scopus_url ]
        end

        it 'renders the scopus link' do
          expect(subject).to have_css('.scopus-backlink')
        end
      end

      context 'when document has no scopus url' do
        it 'does not render the scopus link' do
          expect( subject ).to_not have_css('.scopus-backlink')
        end
      end
    end

    context 'when document has no scopus source' do
      it 'does not render the scopus link' do
        expect( subject ).to_not have_css('.scopus-backlink')
      end
    end
  end
end
