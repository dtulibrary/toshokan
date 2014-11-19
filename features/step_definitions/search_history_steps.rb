When /^I go to the search history$/ do
  visit search_history_path
end

Then /^I should( not)? see "(.*?)" in the history$/ do |negate, search|
  css = '.item .constraint .filterValue'
  negate ? page.should_not(have_css(css, :text => search))
         : page.should(have_css(css, :text => search))
end

When /^I delete the search "(.*?)"$/ do |arg1|
  click_link "Delete"
end

# Saved searches

When /^I save the search "(.*?)"$/ do |arg1|
  click_link "Save"
end

Then /^it should( not)? be saved$/ do |negate|
  negate ? page.should(have_link("Save")) : page.should(have_link("Saved"))
end

When /^I unsave the search "(.*?)"$/ do |arg1|
  click_link "Saved"
end

# Alerted searches

When /^I alert the search "(.*?)"$/ do |arg1|
  Alert.stub(:get).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
  Alert.stub(:post).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
  click_link "Alert"
end

Then /^it should( not)? be alerted$/ do |negate|
  negate ? page.should(have_link("Alert")) : page.should(have_link("Alerted"))
end

When /^I remove the alert from the search "(.*?)"$/ do |arg1|
  Alert.stub(:get).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
  Alert.stub(:delete).and_return(double(:success? => true))
  click_link "Alerted"
end

Then /^I should see a constraint with name "(.*?)" and value "(.*?)"$/ do |name, value|
  expect(page).to have_css('.constraint .filterName', text:name)
  expect(page).to have_css('.constraint .filterValues', text:value)
end
