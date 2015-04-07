Given(/^I check "(.*?)"$/) do |input|
  check(input)
end

When(/^I fill in "(.*?)" with "(.*?)"$/) do |field, value|
  fill_in field, :with => value
end

Then(/^the \"(.*?)\" field should be blank$/) do |field|
  expect( field_labeled(field).value ).to be_blank
end

Then(/^the \"(.*?)\" field should contain \"(.*?)\"$/) do |field, value|
  expect( field_labeled(field).value ).to be =~ /#{value}/
end

When %r{^I fill in the form with valid data$} do
  raise 'Form context not set' unless @form
  step %{I fill in the "#{@form}" form with valid data}
end

When %r{^I submit the form$} do
  raise 'Form context not set' unless @form
  step %{I submit the "#{@form}" form}
end

When %r{^I submit the form with valid data$} do
  step %{I fill in the form with valid data}
  step %{I submit the form}
end

Then %r{^I should see the confirmation page$} do
  raise 'Form context not set' unless @form
  step %{I should see the "#{@form}" confirmation page}
end

When %r{^I confirm the form submission$} do
  raise 'Form context not set' unless @form
  step %{I confirm the "#{@form}" form submission}
end
