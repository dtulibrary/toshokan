require 'rspec/expectations'



RSpec::Matchers.define :have_link_to_search_for do |query_field,value|
  include Rails.application.routes.url_helpers
  match do |actual|
    expect(actual).to have_link(value, :href=>catalog_index_path(query_field=>value))
  end
end