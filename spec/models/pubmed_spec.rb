
require 'rails_helper'

describe Pubmed do

  describe ".get_solr_document" do

    it "should create a valid OpenURL from a pubmed response" do
      fields = SolrDocument.field_semantics
      stub_request(:get, /.*/).to_return(File.new("spec/fixtures/pubmed.xml"))
      doc = Pubmed.get_solr_document("24622755")
      expect(doc[fields[:format]]).to eq "article"
      expect(doc[fields[:title]]).to eq "Dementia and cognitive decline in type 2 diabetes and prediabetic stages: towards targeted interventions."
      expect(doc[fields[:issn]].first).to eq "2213-8595"
      expect(doc[fields[:volume]]).to eq "2"
      expect(doc[fields[:issue]]).to eq "3"
      expect(doc[fields[:year]]).to eq "2014"
      expect(doc[fields[:jtitle]].first).to eq "The lancet. Diabetes & endocrinology"
      expect(doc[fields[:pages]].first).to eq "246-255"
      expect(doc[fields[:doi]]).to eq "10.1016/S2213-8587(13)70088-3"
      expect(doc[fields[:abstract]]).to match /Type 2 diabetes is associated with dementia/
      expect(doc[fields[:author]].length).to eq 5
      expect(doc[fields[:author]].first).to eq "Biessels, Geert Jan"
      expect(doc[fields[:affiliation]].length).to eq 5
      expect(doc[fields[:affiliation]].last).to eq "Kaiser Permanente Division of Research, Oakland, CA, USA."
    end

    it "should create a valid OpenURL from another pubmed response" do
      fields = SolrDocument.field_semantics
      stub_request(:get, /.*/).to_return(File.new("spec/fixtures/pubmed2.xml"))
      doc = Pubmed.get_solr_document("24618353")
      expect(doc[fields[:format]]).to eq "article"
      expect(doc[fields[:title]]).to eq "Is screening of relatives for cerebral aneurysms justified?"
      expect(doc[fields[:issn]].first).to eq "1474-4465"
      expect(doc[fields[:year]]).to eq "2014"
      expect(doc[fields[:jtitle]].first).to eq "Lancet neurology"
      expect(doc[fields[:doi]]).to eq "10.1016/S1474-4422(13)70309-0"
      expect(doc[fields[:author]].length).to eq 1
      expect(doc[fields[:author]].first).to eq "Molyneux, Andrew J"
      expect(doc[fields[:affiliation]].length).to eq 1
      expect(doc[fields[:affiliation]].last).to match /Nuffield Department of Surgical Sciences, University of Oxford/
      expect(doc[fields[:pages]]).to be nil
    end

    it "should create a valid OpenURL from another pubmed response" do
      fields = SolrDocument.field_semantics
      stub_request(:get, /.*/).to_return(File.new("spec/fixtures/pubmed3.xml"))
      doc = Pubmed.get_solr_document("24618352")
      expect(doc[fields[:format]]).to eq "article"
      expect(doc[fields[:title]]).to eq "Long-term, serial screening for intracranial aneurysms in individuals with a family history of aneurysmal subarachnoid haemorrhage: a cohort study."
      expect(doc[fields[:issn]].first).to eq "1474-4465"
      expect(doc[fields[:year]]).to eq "2014"
      expect(doc[fields[:jtitle]].first).to eq "Lancet neurology"
      expect(doc[fields[:doi]]).to eq "10.1016/S1474-4422(14)70021-3"
      expect(doc[fields[:abstract]]).to match /Individuals with two or more first-degree relatives who have had aneurysmal subarachnoid haemorrhage/
      expect(doc[fields[:author]].length).to eq 4
      expect(doc[fields[:author]].first).to eq "Bor, A Stijntje E"
      expect(doc[fields[:affiliation]].length).to eq 4
      expect(doc[fields[:affiliation]].first).to match /Department of Neurology and Neurosurgery, Brain Center Rudolf Magnus, University Medical Center Utrecht, Utrecht, Netherlands./
      expect(doc[fields[:pages]]).to be nil
    end
  end

  describe ".get" do
    it "returns nil on error" do
      stub_request(:get, /.*/).to_return(:status => 500)
      expect(Pubmed.get(1234)).to be nil
    end
  end

end
