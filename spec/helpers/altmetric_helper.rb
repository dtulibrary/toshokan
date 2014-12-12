require "rails_helper"

describe AltmetricHelper do
  let(:document) { SolrDocument.new("doi_ss"=>["10.1016/j.tcs.2009.09.015"], "source_id_ss"=>[]) }

  describe '#altmetric_badge' do
    it 'renders altmetric badge for the document' do
      expect( helper.altmetric_badge(document) ).to have_xpath("//div[@class=\"altmetric-embed\" and @data-doi=\"10.1016/j.tcs.2009.09.015\"]")
    end
    it 'includes arxiv id when available' do
      document[:source_id_ss] = ["arxiv:oai:arXiv.org:0801.1253"]
      expect( helper.altmetric_badge(document) ).to have_xpath("//div[@class=\"altmetric-embed\" and @data-doi=\"10.1016/j.tcs.2009.09.015\"]")
    end
    it 'includes pmid when available' do
      document["source_id_ss"] = ["pubmed:21771119"]
      expect( helper.altmetric_badge(document) ).to have_xpath("//div[@class=\"altmetric-embed\" and @data-pmid=\"21771119\"]")

    end
    it "sets default data attributes" do
      expect( helper.altmetric_badge(document) ).to have_xpath("//div[@class=\"altmetric-embed\" and @data-badge-popover=\"left\" and @data-badge-type=\"donut\"]")
    end
    it "allows you to explicitly set the altmetric data attributes" do
      expect( helper.altmetric_badge(document, "data-badge-popover"=>"bottom" ) ).to have_xpath("//div[@class=\"altmetric-embed\" and @data-badge-popover=\"bottom\"]")
      expect( helper.altmetric_badge(document, "data-badge-type"=>"bar" ) ).to have_xpath("//div[@class=\"altmetric-embed\" and @data-badge-type=\"bar\"]")
    end
  end

end
