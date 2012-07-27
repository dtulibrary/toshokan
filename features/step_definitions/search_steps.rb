Given /^I am on the front page$/ do
  visit('/')
end

When /^I search for "(.*?)"$/ do |query|
  fill_in('q', :with => query) 
  click_button('search')
end

Given /^I search for "(.*?)" in the title$/ do |query|
  fill_in('q', :with => query) 
  select 'Title', :from => 'in' 
  click_button('search')
end

Then /^I should see the result page$/ do
  current_path.should == "/"  
end

Then /^I should see (\d+) results$/ do |results|
  page.all("#documents .document").length.should == results.to_i
end

Then /^I should see a document with title "(.*?)"$/ do |title|
  page.should have_selector('.document .index_title a', text: title) 
end