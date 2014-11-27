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
  let(:solr_document) { catalog_controller.get_solr_response_for_doc_id(document_id, {})[1] }
  let(:blacklight_solr_config) { catalog_controller.blacklight_solr_config }
  # let(:user) { FactoryGirl.create(:logged_in_user) }
  #
  before do
    allow(controller).to receive(:blacklight_solr_config).and_return(blacklight_solr_config)
    # allow(controller).to receive(:current_user).and_return(user)
  end

  describe "toc_for" do
    it "should render table of contents" do
      controller.toc_for(solr_document)
    end
  end

end
