require 'rails_helper.rb'

describe 'Riyosha' do

  describe '#find' do
    context 'when api request fails' do
      it 'returns nil' do
        HTTParty.should_receive(:get) { raise Exception }
        Riyosha.find('1234').should be_nil
      end
    end
  end

end
