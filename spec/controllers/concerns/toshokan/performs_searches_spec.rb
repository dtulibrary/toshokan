require 'rails_helper'

describe Toshokan::PerformsSearches do

  controller(ApplicationController) { include Toshokan::PerformsSearches }

  it "provides search_session helper method for views" do
    # This helper is actually provided by Blacklight::Catalog::SearchContext, which is mixed into the module
    expect(controller._helper_methods).to include(:search_session)
  end
end
