class SuggestionsController < ApplicationController
  include Blacklight::SolrHelper

  # Suggests spellings for each word in a phrase
  # Expects solr to have a 'spell' SearchHandler configured to return spelling suggestions
  def spelling
    query_response = blacklight_solr.get 'spell', params: query_params
    render json: sort_suggestions_by_freq(parse_suggestions(query_response))
  end

  # Suggests completions for a word
  # Expects solr to have a 'complete' SearchHandler configured to suggest completions
  def completion
    query_response = blacklight_solr.get 'complete', params: query_params
    render json: parse_suggestions(query_response).values.first
  end

  private

  def query_params
    params.slice(:q)
  end

  # Extract suggestions from Solr response, returning a Hash
  # where each key is a term from the query phrase and each value is
  # the suggestions for that term.
  # @example
  #   query_response = {"responseHeader"=>{"status"=>0, "QTime"=>1}, "spellcheck"=>{"suggestions"=>["metod", {"numFound"=>3, "startOffset"=>0, "endOffset"=>5, "suggestion"=>["metodyka", "metodą", "metody"]}, "collation", "metodyka"]}}
  #   parse_suggestions(query_response)
  #   => {"metod" => ["metodyka", "metodą", "metody"]}
  def parse_suggestions(query_response)
    suggestions_as_hash = {}
    suggestions_array = query_response['spellcheck']['suggestions']
    suggestions_array.each_with_index do |value, index|
      # solr 4.x includes the collations at the end of the suggestions array
      unless query_response['spellcheck'].has_key?('collations')
        return suggestions_as_hash if index == suggestions_array.length-2
      end
      suggestions_as_hash[value] = suggestions_array[index+1]['suggestion'] if index%2 == 0
    end
    suggestions_as_hash
  end

  def sort_suggestions_by_freq(suggestions_hash)
    sorted_hash = {}
    suggestions_hash.each_pair do |term,term_suggestions|
      if term_suggestions.first.kind_of? Hash
        sorted_term_suggestions = term_suggestions.sort { |x,y| y['freq'] <=> x['freq'] }
        # only return the 'word' in the suggestions array
        sorted_hash[term] = sorted_term_suggestions.map {|term_suggestion| term_suggestion['word']}
      else
        sorted_hash[term] = term_suggestions
      end
    end
    sorted_hash
  end


end