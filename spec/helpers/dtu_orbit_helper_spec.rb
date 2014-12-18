require 'rails_helper'

describe DtuOrbitHelper do

  describe '#render_link_to_dtu_orbit?' do
    before do
      @document = SolrDocument.new
    end

    context 'when document has orbit source' do
      before do
        @document['source_ss'] = ['orbit']
      end

      context 'when document has orbit backlink' do
        before do
          @document['backlink_ss'] = ['http://orbit.dtu.dk/en/publications/id(a26904ce-6e2a-4726-a843-9b872e862de1).html']
        end

        it 'returns true' do
          expect( render_link_to_dtu_orbit? @document ).to be_truthy
        end
      end

      context 'when document only has non-orbit backlinks' do
        it 'returns false' do
          expect( render_link_to_dtu_orbit? @document ).to be_falsey
        end
      end

      context 'when document has no backlinks' do
        it 'returns false' do
          expect( render_link_to_dtu_orbit? @document ).to be_falsey
        end
      end
    end

    context 'when document has no orbit source' do
      it 'returns false' do
        expect( render_link_to_dtu_orbit? @document ).to be_falsey
      end
    end
  end

  describe '#link_to_dtu_orbit' do
    before do
      @document = SolrDocument.new
    end

    context 'when document has orbit source' do
      before do
        @document['source_ss'] = ['orbit']
      end
      
      context 'when document has orbit backlink' do
        before do
          @document['backlink_ss'] = ['http://orbit.dtu.dk/en/publications/id(a26904ce-6e2a-4726-a843-9b872e862de1).html']
        end

        it 'renders the DTU ORBIT backlink' do
          expect( link_to_dtu_orbit @document ).to have_css('.dtu-orbit-backlink')
        end
      end

      context 'when document only has non-orbit backlinks' do
        before do
          @document['backlink_ss'] = ['http://some-other-link.com/path']
        end

        it 'does not render a DTU ORBIT backlink' do
          expect( link_to_dtu_orbit @document ).to_not have_css('.dtu-orbit-backlink')
        end
      end

      context 'when document has no backlinks' do
        it 'does not render a DTU ORBIT backlink' do
          expect( link_to_dtu_orbit @document ).to_not have_css('.dtu-orbit-backlink')
        end
      end
    end

    context 'when document has no orbit source' do
      it 'does not render a DTU ORBIT backlink' do
        expect( link_to_dtu_orbit @document ).to_not have_css('.dtu-orbit-backlink')
      end
    end
  end

end
