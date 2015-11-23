require 'rails_helper'

describe Dtu::SearchBuilder::TagFilters do
  let(:user_params) { {'t' => {'dragons' => true}} }
  let(:scope) { CatalogController.new }
  let(:search_builder) { Dtu::SearchBuilder.new(true,scope) }
  before do
    allow(search_builder).to receive(:blacklight_params).and_return(user_params)
  end
  it 'is included in processed_params' do
    allow(scope).to receive(:current_user).and_return(User.new)
    allow(search_builder).to receive(:document_ids_for_tag_name).and_return(['id1','id2'])
    expect(search_builder.processed_parameters[:fq]).to include("cluster_id_ss:(id1 OR id2)")
  end
end
