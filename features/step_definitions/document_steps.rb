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

Then /^I should get a "(.*?)" file$/ do |extension|
	case extension
	when "bib"
  	page.response_headers['Content-Type'].should include "text/x-bibtex"
  when "ris"
  	page.response_headers['Content-Type'].should include "application/x-Research-Info-Systems"
  end
end

Given /^I go to the record page for "(.*?)"$/ do |title|
  steps %{
    And I'm logged in
    And I have searched for "#{title}"
    And I click the link "#{title}"
  }
end

Then /^I should see the citations$/ do
  current_path.should match 'citation'  
end