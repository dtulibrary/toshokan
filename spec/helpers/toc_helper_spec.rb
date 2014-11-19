require "rails_helper"

describe TocHelper do

  let :helper do
    helper = ApplicationController.new # provides :current_user so we can stub it
    helper.extend Blacklight::Catalog # provides :blacklight_config so we can stub it
    helper.extend Blacklight::SolrHelper
    helper.extend CatalogHelper # provides :add_access_filter
    helper.extend TocHelper
    helper
  end
  let(:catalog_controller) { CatalogController.new }
  let(:document_id) {"320004096"}
  let(:solr_document) { catalog_controller.get_solr_response_for_doc_id(document_id, {})[1] }
  let(:blacklight_config) { catalog_controller.blacklight_config }
  let(:user) { FactoryGirl.create(:logged_in_user) }

  before do
    allow(helper).to receive(:blacklight_config).and_return(blacklight_config)
    allow(helper).to receive(:current_user).and_return(user)
  end

  describe "toc_for" do
    it "should render table of contents" do
      helper.toc_for(solr_document)
    end
  end

end