require "rails_helper"

describe CatalogHelper do

  describe 'show_pagination?' do
    before do
      # Using an instance variable instead of let() because that's how the helper method gets @response in runtime
      @response = Blacklight::SolrResponse.new({},{})
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
end
