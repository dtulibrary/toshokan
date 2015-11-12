require 'rails_helper'

describe Dtu::Metrics::DtuOrbitPresenter, type: :view do
  let(:document) { SolrDocument.new }
  let(:presenter) { described_class.new(document, view, {}) }

  describe '#should_render?' do
    subject { presenter.should_render? }

    context 'when document has no orbit source' do
      it 'returns false' do
        expect( subject ).to eq false
      end
    end

    context 'when document has orbit source' do
      before do
        document['source_ss'] = ['orbit']
      end
      context 'when document has orbit backlink' do
        before do
          document['backlink_ss'] = ['http://orbit.dtu.dk/en/publications/id(a26904ce-6e2a-4726-a843-9b872e862de1).html']
        end
        it 'returns true' do
          expect( subject ).to eq true
        end
      end

      context 'when document only has non-orbit backlinks' do
        before do
          document['backlink_ss'] = ['http://snopes.com/a26904ce-6e2a-4726-a843-9b872e862de1.html']
        end
        it 'returns false' do
          expect( subject ).to eq false
        end
      end

      context 'when document has no backlinks' do
        it 'returns false' do
          expect( subject ).to eq false
        end
      end
    end
  end

  describe '#link_to_dtu_orbit' do
    subject { presenter.link_to_dtu_orbit }
    context 'when document has orbit source' do
      before do
        document['source_ss'] = ['orbit']
      end
      
      context 'when document has orbit backlink' do
        before do
          document['backlink_ss'] = ['http://orbit.dtu.dk/en/publications/id(a26904ce-6e2a-4726-a843-9b872e862de1).html']
        end

        it 'renders the DTU ORBIT backlink' do
          expect( subject ).to have_css('.dtu-orbit-backlink')
        end
      end

      context 'when document only has non-orbit backlinks' do
        before do
          document['backlink_ss'] = ['http://some-other-link.com/path']
        end

        it 'does not render a DTU ORBIT backlink' do
          expect( subject ).to_not have_css('.dtu-orbit-backlink')
        end
      end

      context 'when document has no backlinks' do
        it 'does not render a DTU ORBIT backlink' do
          expect( subject ).to_not have_css('.dtu-orbit-backlink')
        end
      end
    end

    context 'when document has no orbit source' do
      it 'does not render a DTU ORBIT backlink' do
        expect( subject ).to_not have_css('.dtu-orbit-backlink')
      end
    end
  end

end
