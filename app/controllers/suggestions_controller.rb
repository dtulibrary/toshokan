class SuggestionsController < ApplicationController
  include Blacklight::SolrHelper

  # Suggests spellings for each word in a phrase
  # Expects solr to have a 'spell' SearchHandler configured to return spelling suggestions
  def spelling
    query_response = blacklight_solr.get 'spell', params: query_params
    render json: parse_suggestions(query_response)
  end

  # Suggests completions for a word
  # Expects solr to have a 'complete' SearchHandler configured to suggest completions
  def completion
    query_response = blacklight_solr.get 'complete', params: query_params
    render json: parse_suggestions(query_response)
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
      return suggestions_as_hash if index == suggestions_array.length-2
      suggestions_as_hash[value] = suggestions_array[index+1]['suggestion'] if index%2 == 0
    end
  end

end