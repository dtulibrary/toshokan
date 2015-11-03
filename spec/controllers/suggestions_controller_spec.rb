require 'rails_helper'

describe SuggestionsController do
  describe 'spelling' do
    let(:expected_response) { {'metod' => ["method", "metodą", "metody", "methods", "metal"],
                               'polyn' => ["poly", "polar", "polem", "poles", "poland"]} }
    it 'suggests spellings for each word in a phrase' do
      get :spelling, q: 'metod polyn'
      expect(response.body).to eq(expected_response.to_json)
    end
  end

  describe 'completion' do
    let(:expected_response) { ["metodyka", "metodą", "metody"] }
    it 'suggests completions for a word' do
      get :completion, q: 'metod'
      expect(response.body).to eq(expected_response.to_json)
    end
  end
end
