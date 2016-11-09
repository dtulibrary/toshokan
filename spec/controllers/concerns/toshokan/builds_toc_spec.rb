require 'rails_helper'

describe Toshokan::BuildsToc do

  controller(ApplicationController) do
    include Toshokan::BuildsToc
    include Blacklight::SolrHelper # provides blacklight_solr_config
    include Toshokan::SearchParametersHelpers # provides add_access_filter
  end

  it "provides dissect_toc_key helper method for views" do
    expect(controller._helper_methods).to include(:dissect_toc_key)
  end

  # let :helper do
  #   helper = ApplicationController.new # provides :current_user so we can stub it
  #   helper.extend Blacklight::Catalog # provides :blacklight_config so we can stub it
  #   helper.extend Blacklight::SolrHelper
  #   helper.extend Toshokan::SearchParametersHelpers # provides :add_access_filter
  #   helper.extend TocHelper
  #   helper
  # end
  let(:catalog_controller) { CatalogController.new }
  let(:document_id) {"320004096"}
  let(:blacklight_solr_config) { catalog_controller.blacklight_solr_config }
  # let(:user) { FactoryGirl.create(:logged_in_user) }
  #
  subject { controller.toc_for(solr_document) } 
  before do
    allow(controller).to receive(:blacklight_solr_config).and_return(blacklight_solr_config)
    # allow(controller).to receive(:current_user).and_return(user)
  end

  context "valid journal" do
    let(:solr_document) { catalog_controller.get_solr_response_for_doc_id(document_id, {})[1] }
    it { should be_a Hash } 
    it "should have the correct keys" do
      expect(subject.keys).to include :issues
      expect(subject.keys).to include :truncated
      expect(subject.keys).to include :current_issue
      expect(subject.keys).to include :previous_issue
      expect(subject.keys).to include :articles
    end
  end
  context "journal without an issn" do
    let(:solr_document) { SolrDocument.new({
        'access_ss'=>['dtupub', 'dtu'], 'alert_timestamp_dt'=>'2016-07-22T11:30:55Z', 'isolanguage_ss'=>['eng'], 'isolanguage_facet'=>['eng'], 'journal_title_ts'=>['Adidas Ag Swot Analysis'], 'journal_title_facet'=>['Adidas Ag Swot Analysis'], 'subformat_s'=>'electronic', 'publisher_ts'=>['MarketLine'], 'holdings_ssf'=>['{"source":"jnl_sfx","fromyear":"2014","type":"electronic"}', '{"source":"jnl_sfx","fromyear":"2015","type":"electronic"}'], 'member_id_ss'=>['559e3622d51a06d95200010d'], 'title_ts'=>['Adidas AG SWOT Analysis'], 'source_ss'=>['jnl_sfx'], 'language_ss'=>['eng'], 'format'=>'journal', 'update_timestamp_dt'=>'1970-01-01T01:00:00Z', 'types_ss'=>['bib:journal:electronic'], 'fulltext_availability_ss'=>['dtu'], 'cluster_id_ss'=>['2279505163'], 'source_id_ss'=>['jnl_sfx:3710000000438430'], 'superformat_s'=>'bib', 'source_ext_ss'=>['dads:jnl_sfx'], 'source_type_ss'=>['other'], 'affiliation_associations_json'=>'{"editor":[],"supervisor":[],"author":[],"inventor":[]}', 'id'=>'175635651', 'fulltext_info_ss'=>['sfx'], '_version_'=>1548597741005832192, 'score'=>16.444307
    })}
    it "does not raise an error" do
      expect{subject}.not_to raise_error
    end
  end
end
