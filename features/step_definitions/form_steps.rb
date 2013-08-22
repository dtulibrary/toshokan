Given /^I check "(.*?)"$/ do |input|
  check(input)
end

When /^I fill in "(.*?)" with "(.*?)"$/ do |field, value|
  fill_in field, :with => value
end
