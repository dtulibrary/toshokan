require "rails_helper"

describe DocumentIdentifiersHelper do
  let(:document) { SolrDocument.new(issn_ss:["00903973", "19457553", "an_issn"], isbn_ss:["1292018313", "9781292018317"], doi_ss:["10.1520/JTE20130029","doinit-right"]) }
  describe "render_doi_link" do
    it "renders doi_link" do
      expect(helper.render_doi_link(document:document, field:"doi_ss")).to eq( "<a href=\"http://dx.doi.org/10.1520/JTE20130029\">10.1520/JTE20130029</a>")
    end
  end
  describe "render_issn"do
    it "formats issn values as necessary" do
      expect(helper.render_issn(document:document, field:"issn_ss")).to eq("0090-3973, 1945-7553, an_i-ssn")
    end
  end
  describe "render_isbn"do
    it "formats isbn values as necessary" do
      expect(helper.render_isbn(document:document, field:"isbn_ss")).to eq("978-1-292-01831-7, 978-1-292-01831-7")
    end
  end

  it "render_issn_index renders the issn values" do
    expect(helper.render_issn_index(document:document, field:"issn_ss")).to eq("0090-3973, 1945-7553, an_i-ssn")
  end
  it "render_issn_show uses <br> as a separator between values" do
    expect(helper.render_issn_show(document:document, field:"issn_ss")).to eq("0090-3973<br>1945-7553<br>an_i-ssn")
  end
  it "render_isbn_index renders the isbn values" do
    expect(helper.render_isbn_index(document:document, field:"isbn_ss")).to eq("978-1-292-01831-7, 978-1-292-01831-7")
  end
  it "renders_isbn_show uses <br> as a separator between values" do
    expect(helper.render_isbn_show(document:document, field:"isbn_ss")).to eq("978-1-292-01831-7<br>978-1-292-01831-7")
  end

end