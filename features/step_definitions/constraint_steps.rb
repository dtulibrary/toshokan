Then /^I should(?:n't| not) see any links to remove the constraint$/ do
  within '#appliedParams .constraint' do
    should_not have_css 'a.remove-filter'
  end
end

Then /^the "(.*?)" facet should be constrained to "(.*?)"$/ do |name, value|
  within '#appliedParams .constraint' do
    should have_css('.filterName', :text => "#{name}:")
    should have_css('.filterValue', :text => value)
  end
end
