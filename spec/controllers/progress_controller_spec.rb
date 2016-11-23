require 'rails_helper'

describe ProgressController do
  describe '#show' do
    it 'returns json describing progress' do
      name = 'I think'
      Progress.create(:name => name)
      xhr :get, :show, :format => :json, :name => name
      expect(response).to be_success
      expect(JSON.parse(response.body)).to be_a(Hash)
    end

    context 'when progress object does not exist' do
      it 'raises a routing error' do
        expect {
          xhr :get, :show, :format => :json, :name => 'I don\'t exist'
        }.to raise_error(ActionController::RoutingError)
      end
    end

  end

end
