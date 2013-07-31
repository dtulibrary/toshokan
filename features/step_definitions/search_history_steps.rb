When /^I go to the search history$/ do
  visit search_history_path
end

Then /^I should see a constraint with name "(.*?)" and value "(.*?)"$/ do |name, value|
  pending("Constraints temporarily disabled") do
    within('.constraint') do
      find('.filterName').should have_content name
      find('.filterValue').should have_content value
    end
  end
end
