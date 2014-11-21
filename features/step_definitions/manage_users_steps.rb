Given /^I(?: a|')m on the user management page$/ do
  visit users_path
end

When /^I go to the user management page$/ do
  visit users_path
end

Then /^I should be on the user management page$/ do
  expect(page.body).to have_content 'Manage Users'
end

When /^I (add|remove) role "(.+?)" (?:to|from) user with (\w+) "(.+?)"$/ do |action, role_name, key, value|
  role = Role.find_by_name role_name
  user = find_user key, value
  role_checkbox(user, role).set action == 'add'
end

When /^I save(?: the)? user with (\w+) "(.*?)"$/ do |key, value|
  user = find_user key, value
  save_user_button(user).click
end

Then /^the user with (\w+) "(.+?)" should((?: not|n't))? have role "(.+?)"$/ do |key, value, negate, role_name|
  role = Role.find_by_name role_name
  user = find_user key, value
  checkbox = page.find(:css, "form[data-identifier = '#{user.identifier}'] input[data-role_id = '#{role.id}']")
  if negate
    expect(checkbox).to_not be_checked
  else
    expect(checkbox).to be_checked
  end
end

def role_checkbox user, role
  page.find("form[data-identifier = '#{user.identifier}'] input[data-role_id = '#{role.id}']")
end

def save_user_button user
  page.find("form[data-identifier = '#{user.identifier}'] input[type = 'submit']")
end
