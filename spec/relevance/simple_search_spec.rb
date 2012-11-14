require 'spec_helper'
require 'rspec-solr'

describe "Title search", :relevance => true do

	it "The title for the first record when searching on 'nanotechnology' should be 'Nanotechnology'" do
		resp = solr_response({'q' => 'nanotechnology'})
		resp.should include("title_t" => "Nanotechnology").as_first_result
	end

end