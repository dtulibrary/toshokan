require 'rails_helper'

describe Toshokan::Catalog do

  controller(CatalogController){}

  describe "export_search_result" do
    it "exports ris" do
      allow_any_instance_of(SolrDocument).to receive(:export_as).with(:ris).and_return("BIBEXPORT")
      expected_result = Array.new(4) { "BIBEXPORT" }.join("\n\n")
      expect(controller.export_search_result(:ris, {q:"Polski"})).to eq(expected_result)
    end
    it "exports bib" do
      pending "This appears to be broken.  Is it used?"
      fail
      expect(controller.export_search_result(:bib, {q:"Polski"})).to eq("BIBEXPORT\n\nBIBEXPORT\n\nBIBEXPORT\n\nBIBEXPORT")
    end
  end
  it "journal_document_for_issns" do
    issns = ["an_issn"]
    solr_response = {response:{docs:["first document", "second document"]} }
    allow(controller).to receive(:get_solr_response_for_field_values).with("issn_ss", issns, {:fq=>["format:journal", "access_ss:dtupub"], :rows=>1}).and_return([solr_response])
    expect(controller.journal_document_for_issns(issns)).to eq "first document"
  end
  it "journal_id_for_issns" do
    issns = ["an_issn"]
    expect(controller).to receive(:journal_document_for_issns).with(issns).and_return({cluster_id_ss:"the ID"})
    expect(controller.journal_id_for_issns(issns)).to eq "the ID"
  end
end