require 'rails_helper'

describe SuggestionsController do
  describe 'spelling' do
    # TODO: Fix the suggestions by modifying the 'spellcheck' searchComponent in the solrconfig.xml
    # This tests that the stack is working properly.
    # Obviously these aren't the kind of suggestions we actually want
    let(:expected_response) {
      {
          "metod"=>["m et o d", "m et od", "met o d", "me t od", "method", "met od", "metodą", "metody", "metoda"],
          "polyn"=>["p o ly n", "p ol y n", "poly n", "po ly n", "pol y n", "poly", "polar", "poles", "polem", "poland"]
      }
    }
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

  describe 'parse_suggestions' do
    subject { controller.send(:parse_suggestions, query_response) }
    describe 'solr5' do
      let(:query_response) { {"responseHeader"=>{"status"=>0, "QTime"=>0}, "spellcheck"=>{"suggestions"=>["metod", {"numFound"=>3, "startOffset"=>0, "endOffset"=>5, "suggestion"=>["metodyka", "metodą", "metody"]}], "collations"=>["collation", "metodyka"]}} }
      it 'returns the suggestions' do
        expect(subject).to eq( {"metod" => ["metodyka", "metodą", "metody"]} )
      end
    end

    describe 'solr4' do
      let(:query_response) { {"responseHeader"=>{"status"=>0, "QTime"=>1}, "spellcheck"=>{"suggestions"=>["metod", {"numFound"=>3, "startOffset"=>0, "endOffset"=>5, "suggestion"=>["metodyka", "metodą", "metody"]}, "collation", "metodyka"]}} }
      it 'returns the suggestions' do
        expect(subject).to eq( {"metod" => ["metodyka", "metodą", "metody"]} )
      end
    end
  end

  describe 'sort_suggestions_by_freq' do
    let(:suggestions_hash) { {"metod"=>[{"word"=>"met od", "freq"=>103}, {"word"=>"method", "freq"=>153}, {"word"=>"m et od", "freq"=>320}, {"word"=>"metodą", "freq"=>53}, {"word"=>"met o d", "freq"=>228}, {"word"=>"metody", "freq"=>36}, {"word"=>"me t od", "freq"=>172}, {"word"=>"metoda", "freq"=>12}, {"word"=>"m et o d", "freq"=>320}], "polyn"=>[{"word"=>"poly", "freq"=>5}, {"word"=>"poly n", "freq"=>210}, {"word"=>"polar", "freq"=>5}, {"word"=>"po ly n", "freq"=>210}, {"word"=>"polem", "freq"=>3}, {"word"=>"pol y n", "freq"=>210}, {"word"=>"poles", "freq"=>3}, {"word"=>"p ol y n", "freq"=>319}, {"word"=>"poland", "freq"=>2}, {"word"=>"p o ly n", "freq"=>319}]} }
    subject { controller.send(:sort_suggestions_by_freq, suggestions_hash) }
    it 'reduces lists of suggestions to an array of words, sorted by frequency values' do
      expect(subject).to eq({"metod"=>["m et o d", "m et od", "met o d", "me t od", "method", "met od", "metodą", "metody", "metoda"], "polyn"=>["p o ly n", "p ol y n", "poly n", "po ly n", "pol y n", "poly", "polar", "poles", "polem", "poland"]})
    end
  end
end
