require 'rails_helper'

describe IsiHelper do
  let(:document) { SolrDocument.new }
  let(:valid_isi_url) { 'http://ws.isiknowledge.com/cps/openurl/service?url_ver=Z39.88-2004&rft_id=info%3Aut%2F000366928800014' }
  let(:invalid_isi_url) { 'http://somethingelse.com/cps/openurl/service?url_ver=Z39.88-2004&rft_id=info%3Aut%2F000366928800014' }

  describe '#render_link_to_isi?' do
    subject { render_link_to_isi?(document) }

    context 'when document has isi source' do
      before do
        document['source_ss'] = ['isi']
        document['backlink_ss'] = [ backlink ]
      end

      context 'when document has isi url' do
        let(:backlink) { valid_isi_url }
        it { should be true }
      end

      context "when document has invalid isi url" do
        let(:backlink) { invalid_isi_url }
        it { should be false }
      end

      context 'when document has no isi url' do
        let(:backlink) { '' }
        it { should be false }
      end
    end

    context 'when document has no isi source' do
      it { should be false }
    end
  end

  describe '#link_to_isi' do
    subject{ link_to_isi(document) }
    context 'when document has isi source' do
      before do
        document['source_ss'] = ['isi']
      end

      context 'when document has isi url' do
        before do
          document['backlink_ss'] = [ valid_isi_url ]
        end

        it 'renders the isi link' do
          expect(subject).to have_css('.isi-backlink')
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
