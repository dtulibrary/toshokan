Then /^I should see "(.*?)"$/ do |content|
  page.should have_content content
end

Then /^I should(?: not|n't) see "(.*?)"$/ do |content|
  page.should_not have_content content
end

Then /^show me the page$/ do 
  save_and_open_page 
end

When /^I click "(.*?)"$/ do |name|
  click_link_or_button name
end

Given /^I click the link "(.*?)"$/ do |link|
  click_link link
end
