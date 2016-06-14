require 'rails_helper'

RSpec.describe RefineSearchController, :type => :controller do
  describe "#parse_search_query" do
    it "returns JSON" do
      stub_request(:post, "http://freecite.library.brown.edu/citations/create").
        to_return(:status => 200, :body => "", :headers => {})

      get(:parse_search_query, {"q" => "query query query"})

      expect(response.header["Content-Type"]).to include("application/json")
      parsed_response = JSON.parse(response.body)
    end

    it "reponds with HTTP status = 422 and a body with an error message when no query is passed" do
      stub_request(:post, "http://freecite.library.brown.edu/citations/create").
        to_return(:status => 200, :body => "", :headers => {})

      get(:parse_search_query, { })

      expect(response.status).to eq(422)
      expect(response.body).to match(/must not be empty/)
    end

    it "parses an already refined query" do
      stub_request(:post, "http://freecite.library.brown.edu/citations/create").
        to_return(:status => 200, :body => "", :headers => {})

      get(:parse_search_query, { "q" => 'journal_title:"Test Journal" title:"Test Title"'})

      parsed_response = JSON.parse(response.body)
      expect(parsed_response["journal_title"]).to eq("Test Journal")
      expect(parsed_response["title"]).to eq("Test Title")
    end
  end
end
