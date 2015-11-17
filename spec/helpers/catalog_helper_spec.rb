require "rails_helper"

describe CatalogHelper do

  describe 'show_pagination?' do
    before do
      # Using an instance variable instead of let() because that's how the helper method gets @response in runtime
      @response = Blacklight::Solr::Response.new({},{})
    end
    it "should return false if there is no document limit or if there is only one page" do
      @response = double("SolrResponse", limit_value:0)
      expect( helper.show_pagination? ).to be_falsey
      @response = double("SolrResponse", limit_value:50, total_pages:1)
      expect( helper.show_pagination? ).to be_falsey
    end
    it "should return true if there is no document limit or if there is only one page" do
      @response = double("SolrResponse", limit_value:50, total_pages:2)
      expect( helper.show_pagination? ).to be_truthy
    end
  end

  describe "extra_body_classes" do
    it "adds controller name and action with blacklight-prefix" do
      allow(helper).to receive(:params).and_return({})
      allow(helper).to receive(:controller).and_return(double(controller_name:"fake", action_name:"show"))
      expect(helper.extra_body_classes).to eq ["blacklight-fake", "blacklight-fake-show"]
    end
    it "uses defaults if params[:resolve] is set" do
      allow(helper).to receive(:params).and_return({resolve:"foo"})
      expect(helper.extra_body_classes).to eq ["blacklight-catalog", "blacklight-catalog-show"]
    end
  end


end
