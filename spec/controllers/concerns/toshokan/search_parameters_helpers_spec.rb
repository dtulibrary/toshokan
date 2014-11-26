require 'rails_helper'

describe Toshokan::SearchParametersHelpers do
  controller(CatalogController) {}
  describe "add_access_filter" do
    it "adds requested filter along with necessary access filter" do
      controller.add_access_filter({:fq => ['format:journal'], :rows => 1})
      expect( controller.add_access_filter({:fq => ['format:journal'], :rows => 1}) ).to eq( {:fq=>["format:journal", "access_ss:dtupub"], :rows=>1} )
    end
  end
  describe "add_inclusive_access_filter" do
    it "adds requested filter along with necessary access filter" do
      controller.add_access_filter({:fq => ['format:journal'], :rows => 1})
      expect( controller.add_inclusive_access_filter({:fq => ['format:journal'], :rows => 1}) ).to eq( {:fq=>["format:journal", "access_ss:(dtu OR dtupub)"], :rows=>1} )
    end
  end
end