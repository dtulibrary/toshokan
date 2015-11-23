require 'rails_helper'

describe Dtu::SearchBuilder::AccessFilters do
  let(:scope) { double }
  let(:search_builder) { Dtu::SearchBuilder.new({},scope) }
  before do
    allow(scope).to receive(:can?).and_return false
  end
  describe "add_access_filter" do
    subject { search_builder.add_access_filter({:fq => ['format:journal'], :rows => 1}) }
    context 'default access' do
      it "adds requested filter along with necessary access filter" do
        expect( subject ).to eq( {:fq=>["format:journal"], :rows=>1} )
      end
    end
    context 'with public access' do
      before do
        allow(scope).to receive(:can?).with(:search, :public).and_return true
      end
      it "adds requested filter along with necessary access filter" do
        expect( subject ).to eq( {:fq=>["format:journal", "access_ss:dtupub"], :rows=>1} )
      end
    end
    context 'with dtu access' do
      before do
        allow(scope).to receive(:can?).with(:search, :public).and_return true
        allow(scope).to receive(:can?).with(:search, :dtu).and_return true
      end
      it "adds requested filter along with necessary access filter" do
        expect( subject ).to eq( {:fq=>["format:journal", "access_ss:dtu", "access_ss:dtupub"], :rows=>1} )
      end
    end

  end
  describe "add_inclusive_access_filter" do
    it "adds requested filter along with necessary access filter" do
      expect( search_builder.add_inclusive_access_filter({:fq => ['format:journal'], :rows => 1}) ).to eq( {:fq=>["format:journal", "access_ss:(dtu OR dtupub)"], :rows=>1} )
    end
  end
end
