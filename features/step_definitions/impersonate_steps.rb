Given /^I(?: ha|')ve switched user from user with (.*?) "(.*?)" to user with (.*?) "(.*?)"$/ do |key1, value1, key2, value2|
  step "I'm logged in as user with #{key1} \"#{value1}\""
  step "I switch user to user with #{key2} \"#{value2}\""
end

When /^I switch user to user with (.*?) "(.*?)"$/ do |key, value|
  click_link 'Switch User'
  fill_in "User name or CWIS number", with: value
  click_button 'Switch User'
end
