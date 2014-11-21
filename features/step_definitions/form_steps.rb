Given /^I check "(.*?)"$/ do |input|
  check(input)
end

When /^I fill in "(.*?)" with "(.*?)"$/ do |field, value|
  fill_in field, :with => value
end

Then /^the \"(.*?)\" field should be blank$/ do |field|
  expect( field_labeled(field).value ).to be_blank
end

Then /^the \"(.*?)\" field should contain \"(.*?)\"$/ do |field, value|
  expect( field_labeled(field).value ).to be =~ /#{value}/
end
