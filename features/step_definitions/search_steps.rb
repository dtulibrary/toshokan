Given /^I am on the front page$/ do
  visit(root_path)
end

When /^I search for "(.*?)"$/ do |query|
  fill_in('q', :with => query) 
  click_button('search')
end

Given /^I search for "(.*?)" in the title$/ do |query|
  step "I search for \"#{query}\" in the \"Title\" field"
end

Given /^I search for "(.*?)" in the "(.*?)" field$/ do |query, field|
  fill_in('q', :with => query) 
  select field, :from => 'in' 
  click_button('search')
end

Given /^I have the limited the "(.*?)" facet to "(.*?)"$/ do |facet_name, facet_value|
  click_link(facet_value)
end

Then /^I should see the result page$/ do
  current_path.should == "/"  
end

Then /^I should see (\d+) documents?$/ do |results|
  page.all("#documents .document").length.should == results.to_i
end

Then /^I should see a document with title "(.*?)"$/ do |title|
  page.should have_selector('.document .index_title a', text: title) 
end
