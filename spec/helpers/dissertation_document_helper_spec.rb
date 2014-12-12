require "rails_helper"

describe DissertationDocumentHelper do
  describe "render_dissertation_date" do
    it "tries to convert value to long-format date" do
      document = SolrDocument.new("dissertation_date_ssf"=>["2014-04-09T11:31:03.582Z"])
      expect(helper.render_dissertation_date(document:document, field:"dissertation_date_ssf")).to eq("April 09, 2014")
    end
    it "fails back to displaying the value as text" do
      document = SolrDocument.new("dissertation_date_ssf"=>["1994"])
      expect(helper.render_dissertation_date(document:document, field:"dissertation_date_ssf")).to eq("1994")
    end
  end
end