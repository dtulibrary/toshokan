Given /^I am on the front page$/ do
  visit(root_path)
end

Given /^I(?:'m| am) on the search page/ do
  visit catalog_index_path
end

Given /^I(?: a|')m on the advanced search page$/ do
  visit(advanced_path)
end

Given /^I(?:'ve| have) searched for "(.*?)"$/ do |q|
  step %{I'm on the search page}
  step %{I search for "#{q}"}
end

When /^I search for "(.*?)"$/ do |query|
  fill_in('q', :with => query) 
  click_button('Find it')
end

Given /^I search for "(.*?)" in the title$/ do |query|
  step "I search for \"#{query}\" in the \"Title\" field"
end

Given /^I search for "(.*?)" in the "(.*?)" field$/ do |query, field|
  visit(catalog_index_path)
  if page.has_selector? '.advanced-search'
    fill_in field, :with => query
  else 
    select field, :from => 'in'
    fill_in('q', :with => query) 
  end
  click_button('Find it')
end

Given /^I have limited the "(.*?)" facet to "(.*?)"$/ do |facet_name, facet_value|
  click_link(facet_value)
end

Then /^I should see the result page$/ do
  current_path.should match(/^\/(en|da)\/catalog$/)  
end

Then /^I should see (\d+) documents?$/ do |results|
  page.all("#documents .document").length.should == results.to_i
end

Then /^I should see a document with title "(.*?)"$/ do |title|
  page.should have_selector('.document .index_title a', text: title) 
end

Then /^I should((?:n'| no)t)? see the advanced search form$/ do |negate|
  if negate 
    page.should_not have_selector('.advanced-search')
  else 
    page.should have_selector('.advanced-search')
  end
end

Then /^I should((?:n'| no)t)? see the simple search form$/ do |negate|
  if negate
    page.should_not have_selector('#q')
  else
    page.should have_selector('#q')
  end
end
