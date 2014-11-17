
require 'rails_helper'

describe Pubmed do

  describe ".get_solr_document" do

    it "should create a valid OpenURL from a pubmed response" do
      fields = SolrDocument.field_semantics
      stub_request(:get, /.*/).to_return(File.new("spec/fixtures/pubmed.xml"))
      doc = Pubmed.get_solr_document("24622755")
      doc[fields[:format]].should eq "article"
      doc[fields[:title]].should eq "Dementia and cognitive decline in type 2 diabetes and prediabetic stages: towards targeted interventions."
      doc[fields[:issn]].first.should eq "2213-8595"
      doc[fields[:volume]].should eq "2"
      doc[fields[:issue]].should eq "3"
      doc[fields[:year]].should eq "2014"
      doc[fields[:jtitle]].first.should eq "The lancet. Diabetes & endocrinology"
      doc[fields[:pages]].first.should eq "246-255"
      doc[fields[:doi]].should eq "10.1016/S2213-8587(13)70088-3"
      doc[fields[:abstract]].should match /Type 2 diabetes is associated with dementia/
      doc[fields[:author]].length.should eq 5
      doc[fields[:author]].first.should eq "Biessels, Geert Jan"
      doc[fields[:affiliation]].length.should eq 5
      doc[fields[:affiliation]].last.should eq "Kaiser Permanente Division of Research, Oakland, CA, USA."
    end

    it "should create a valid OpenURL from another pubmed response" do
      fields = SolrDocument.field_semantics
      stub_request(:get, /.*/).to_return(File.new("spec/fixtures/pubmed2.xml"))
      doc = Pubmed.get_solr_document("24618353")
      doc[fields[:format]].should eq "article"
      doc[fields[:title]].should eq "Is screening of relatives for cerebral aneurysms justified?"
      doc[fields[:issn]].first.should eq "1474-4465"
      doc[fields[:year]].should eq "2014"
      doc[fields[:jtitle]].first.should eq "Lancet neurology"
      doc[fields[:doi]].should eq "10.1016/S1474-4422(13)70309-0"
      doc[fields[:author]].length.should eq 1
      doc[fields[:author]].first.should eq "Molyneux, Andrew J"
      doc[fields[:affiliation]].length.should eq 1
      doc[fields[:affiliation]].last.should match /Nuffield Department of Surgical Sciences, University of Oxford/
      doc[fields[:pages]].should be nil
    end

    it "should create a valid OpenURL from another pubmed response" do
      fields = SolrDocument.field_semantics
      stub_request(:get, /.*/).to_return(File.new("spec/fixtures/pubmed3.xml"))
      doc = Pubmed.get_solr_document("24618352")
      doc[fields[:format]].should eq "article"
      doc[fields[:title]].should eq "Long-term, serial screening for intracranial aneurysms in individuals with a family history of aneurysmal subarachnoid haemorrhage: a cohort study."
      doc[fields[:issn]].first.should eq "1474-4465"
      doc[fields[:year]].should eq "2014"
      doc[fields[:jtitle]].first.should eq "Lancet neurology"
      doc[fields[:doi]].should eq "10.1016/S1474-4422(14)70021-3"
      doc[fields[:abstract]].should match /Individuals with two or more first-degree relatives who have had aneurysmal subarachnoid haemorrhage/
      doc[fields[:author]].length.should eq 4
      doc[fields[:author]].first.should eq "Bor, A Stijntje E"
      doc[fields[:affiliation]].length.should eq 4
      doc[fields[:affiliation]].first.should match /Department of Neurology and Neurosurgery, Brain Center Rudolf Magnus, University Medical Center Utrecht, Utrecht, Netherlands./
      doc[fields[:pages]].should be nil
    end
  end

  describe ".get" do
    it "returns nil on error" do
      stub_request(:get, /.*/).to_return(:status => 500)
      Pubmed.get(1234).should be nil
    end
  end

end
