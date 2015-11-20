require 'spec_helper'

describe Dtu::SearchBuilder do

  it 'is a Blacklight::SearchBuilder with all of the custom modules included' do
    expect(described_class.included_modules).to include(Blacklight::Solr::SearchBuilderBehavior, Dtu::SearchBuilder::AccessFilters, Dtu::SearchBuilder::AppliesLimitQueries, Dtu::SearchBuilder::TagFilters)
  end

end