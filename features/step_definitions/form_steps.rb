Given /^I check "(.*?)"$/ do |input|
  check(input)
end

When /^I fill in "(.*?)" with "(.*?)"$/ do |field, value|
  fill_in field, :with => value
end

Then /^the \"(.*?)\" field should be blank$/ do |field|
  field_labeled(field).value.should be_blank
end

Then /^the \"(.*?)\" field should contain \"(.*?)\"$/ do |field, value|
  field_labeled(field).value.should =~ /#{value}/
end
