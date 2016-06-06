require 'uri'

class RefineSearchController < ApplicationController
  def parse_search_query
    query = URI.decode(params[:q] || "")

    if query.nil? || query.empty?
      render status: :unprocessable_entity, text: "paramter 'q' must not be empty."
      return
    end

    if already_refined?(query)
      render json: parse_refined_query_to_jsonable_structure(query)
      return
    end

    freecite_response = FreeciteHelper::FreeciteRequest.new(query).call
    render json: map_freecite_response_to_jsonable_toshokan_response(freecite_response)
  end

  private

  def map_freecite_response_to_jsonable_toshokan_response(freecite_response)
    {
      "authors" => freecite_response.unabbreviated_names_of_the_first_author,
      "journal_title" => freecite_response.journal_title,
      "volume" => freecite_response.volume,
      "pages" => freecite_response.pages,
      "publisher" => freecite_response.publisher,
      "year" => freecite_response.year,
      "title" => freecite_response.title
    }
  end

  def already_refined?(query)
    query.include?(':') && query.include?('"')
  end

  def parse_refined_query_to_jsonable_structure(query)
    {
      "authors" => parse_field_from_refined_query("authors", query),
      "journal_title" => parse_field_from_refined_query("journal_title", query),
      "volume" => parse_field_from_refined_query("volume", query),
      "pages" => parse_field_from_refined_query("pages", query),
      "publisher" => parse_field_from_refined_query("publisher", query),
      "year" => parse_field_from_refined_query("year", query),
      "title" => parse_field_from_refined_query("title", query)
    }
  end

  def parse_field_from_refined_query(fieldname, query)
    Regexp.new('(?:^|\s)' + fieldname + ':"([^"]+)"')
      .match(query) { |match| match[1] } || ""
  end
end
