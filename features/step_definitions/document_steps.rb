When(/^I click on the first document$/) do
  step 'I click on the title for the first of the results'
end

When(/^I click on the title for the first of the results$/) do
  first('.index_title > a').click
end

When(/^I go to the next document$/) do
  page.find('#previousNextDocument .next').click
end

Then(/^I should see one or more documents$/) do
  expect(page).to have_css('.document')
end

Then(/^I should see the page for a single document$/) do
  expect(page).to have_css('.blacklight-catalog-show')
end

Then(/^I should get a "(.*?)" file$/) do |extension|
  case extension
  when "bib"
    expect(page.response_headers['Content-Type']).to include "text/x-bibtex"
  when "ris"
    expect(page.response_headers['Content-Type']).to include "application/x-Research-Info-Systems"
  end
end

Then %r{^I should see the (".*") fields$} do |fields|
  fields.scan(/"(.+?)"/) do |field,_|
    step "I should see the \"#{field}\" field"
  end
end

Then %r{^I should see the "(.+?)" field$} do |field|
  step "I should see \"#{field}\""
end

Given(/^I go to the record page for "(.*?)"$/) do |title|
  step "I have searched for \"title:(#{title})\""
  step "I click the link \"#{title}\""
end

Then(/^I should see the citations$/) do
  expect(current_path).to match 'citation'
end

Then(/^I should see the document titled "(.*?)"$/) do |title|
  expect(page).to have_css('.document dd', :text => title)
end

Given(/^I go to the standalone page for id "(.*?)"$/) do |id|
  visit solr_document_path(:id => id)
end

When(/^I click the link for journal "(.*?)"$/) do |title|
  allow(Alert).to receive(:get).and_return(double(:success? => false, :body => "null", :code => 404))
  step "I click the link \"#{title}\""
end
