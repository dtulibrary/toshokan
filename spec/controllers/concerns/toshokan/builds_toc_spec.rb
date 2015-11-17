require 'rails_helper'

describe Toshokan::BuildsToc do

  controller(ApplicationController) do
    include Toshokan::BuildsToc
    include Blacklight::SearchHelper # provides blacklight_config
    include Toshokan::SearchParametersHelpers # provides add_access_filter
  end

  it "provides dissect_toc_key helper method for views" do
    expect(controller._helper_methods).to include(:dissect_toc_key)
  end

  describe "toc_for" do
    let(:catalog_controller) { CatalogController.new }
    let(:document_id) {"320004096"}
    let(:solr_document) { catalog_controller.fetch(document_id, {})[1] }
    it "should render table of contents" do
      controller.toc_for(solr_document)
    end
  end

end
