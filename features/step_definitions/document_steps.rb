Given /^I have searched for "(.*?)"$/ do |query|
  visit('/')  
  fill_in('q', :with => query) 
  click_button('search')  
end

When /^I click on the title for the first of the results$/ do
  first('.index_title').find('a').click
end

Then /^I should see the page for a single document$/ do
  page.should have_css('.blacklight-catalog-show')
end
