require 'rails_helper'

describe Toshokan::AssociatesSearchesWithUsers do

  controller(CatalogController) {}
  let(:user) { User.create }
  let(:other_user) { User.create }
  let(:repeated_params) { { "q" => "cymothoa exigua" } }
  let(:original_search) { user.searches.create(query_params:repeated_params.merge({"controller"=>"catalog", "action"=>"index"}) ) }

  before do
    original_search.save
  end
  it "only stores a search once per user" do
    expect(user.searches.count).to eq 1
    login user
    get :index, repeated_params
    expect(user.searches.count).to eq 1
    expect(user.searches.last).to eq original_search
  end
  it "does not steal searches from other users" do
    login other_user
    get :index, repeated_params
    expect(other_user.searches.count).to eq 1
    expect(user.searches.count).to eq 1
    # expect(other_user.searches.last).to be_a_new(Search)
    expect(other_user.searches.last).to_not eq original_search
    expect(other_user.searches.last.query_params).to eq original_search.query_params
  end
  it "doesn't save default 'empty' search" do
    login user
    user_searches_before = user.searches.all.load
    get :index, "utf8"=>"✓", "search_field"=>"all_fields", "locale"=>"en"
    expect(user.reload.searches).to eq user_searches_before
  end
  it "should reorder user searches to match user's actual search history (repeating a search puts it at the top fo your history)" do
    user.searches.create( query_params: {"q"=>"phronima sedentaria","controller"=>"catalog", "action"=>"index"} )
    user.searches.create( query_params: {"q"=>"pyrosome","controller"=>"catalog", "action"=>"index"} )
    expect(user.searches.order("updated_at DESC").first.query_params).to eq( {"q"=>"pyrosome","controller"=>"catalog", "action"=>"index"})
    login user
    get :index, repeated_params
    user.reload
    expect(user.searches.order("updated_at DESC").first).to eq( original_search )
  end
# end
end