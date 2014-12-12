require 'rails_helper.rb'

describe 'Riyosha' do

  describe '#find' do
    context 'when api request fails' do
      it 'returns nil' do
        expect(HTTParty).to receive(:get) { raise Exception }
        expect(Riyosha.find('1234')).to be_nil
      end
    end
  end

end
