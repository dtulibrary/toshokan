When /^I switch user to user with (.*?) "(.*?)"$/ do |key, value|
  click_link 'Switch user'
  fill_in "user_q", with: value
  click_button 'Search for user'
  within ".found_user" do
    click_button 'Become user'
  end
end

Then /^I should see "(.*?)" in the list of users$/ do |content|
  find('.found_users').should have_content content
end

Then /^I should(?: not|n't) see "(.*?)" in the list of users$/ do |content|
  find('.found_users').should_not have_content content
end

Then /^the original user should be "(.*?)"$/ do |username|
  find('#util-links #original-user').should have_content (username + " acting as")
end

Given /^I(?: ha|')ve switched user from user with (.*?) "(.*?)" to user with (.*?) "(.*?)"$/ do |key1, value1, key2, value2|
  step "I'm logged in as user with #{key1} \"#{value1}\""
  step "I switch user to user with #{key2} \"#{value2}\""
end

Then /^I should not see personalized features$/ do
  step "I should not see \"Manage tags\""
  step "I should not see \"Search history\""
  step "I should not see \"Alerted journals\""
end

Then /^I should see personalized features$/ do
  step "I should see \"Manage tags\""
  step "I should see \"Search history\""
  step "I should see \"Alerted journals\""
end
