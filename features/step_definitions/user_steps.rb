# encoding: utf-8

Given /^I have(?: not|n't) logged in$/ do
  # For narrative purposes in features
end

Then /^the user should be "(.*?)"$/ do |username|
  page.should have_selector '#util-links a', :text => username
end

Given /^the following DTU employee users? exists?:$/ do |table|
  table.map_column!('roles') { |roles| roles.scan(/"(.*?)"/).flatten }
  table.hashes.each do |hash|
    hash['name'] ||= 'John Doe'

    user = mock_dtu_user(hash['identifier'], hash['email'], 'employee', hash['name'])
    hash['roles'].each { |role| user.roles << Role.find_by_name(role) }
    user.save!
  end
end

Given /^user with identifier "(.*?)" has role "(.*?)"$/ do |arg1, arg2|
  user = User.find_by_identifier(arg1)
  user.roles << Role.find_by_name(arg2)
  user.save!
end

Given /^I'm logged in as user with the role "(.*?)"$/ do |arg1|
  role = Role.find_by_name(arg1)
  raise "Role doesn't exist for name #{arg1}" unless role
  user = User.new(identifier: arg1+'_test_id', username: arg1+'_test_username', provider: 'dtu_cas') 
  user.roles = [role]
  user.save!
  log_in(user)
end

Given /^I'm logged in as user with identifier "(.*?)"?$/ do |arg1|
  log_in(User.find_by_identifier(arg1))
end

Given /^I'm logged in(?: as user with no roles?)?$/ do
  log_in(mock_user('12345678'))
end

Given /^I'm logged in as a public user with email "(.*?)"$/ do |arg1|
  log_in(mock_public_user('12345678', arg1))
end

Given /^I log in$/ do
  steps %{
    Given I'm logged in
  }
end

Given /^I'm logged in as a DTU (user|employee|student|guest)$/ do |arg1|
  log_in(mock_dtu_user('12345678', 'fake.email@example.com', arg1, 'Fake Name'))
end

Given /^I'm logged in as a DTU (user|employee|student|guest) with name "(.*?)"$/ do |arg1, arg2|
  log_in(mock_dtu_user('12345678', 'fake.email@example.com', arg1, arg2))
end

Given /^I'm logged in as a public user$/ do
  log_in(mock_public_user('87654321', 'fake.email@example.com'))
end

Given /^I(?:'m| am) a walk-in user$/ do
  ApplicationController.stub(:walk_in_request?).and_return(true)
end

Given /^I'm an anonymous user$/ do

end

Given /^I'm logged out$/ do

end

def log_in(user)
  Rails.application.config.auth[:stub] = true

  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:cas, {:uid => user.identifier})

  visit('/')
  within '#util-links' do
    click_link 'Log in'
  end
end

Given /^I log out$/ do
  click_link 'Log out'
end

def mock_user(identifier, email='fake.email@example.com', extra_user_data = {})
  user_data = {'id' => identifier, 'email' => email}.deep_merge(extra_user_data)
  Riyosha.config.test_mode = true
  Riyosha.config.add_mock(identifier, user_data)
  User.create_or_update_with_user_data(:cas, user_data)
end

def mock_public_user(identifier, email='fake.email@example.com')
  mock_user(identifier, email, {:provider => 'google'})
end

def mock_dtu_user(identifier, email='fake.email@example.com', user_type='employee', name="Firstname Lastname")
  names = name.split(" ", 2)
  mock_user(identifier, email, {:provider => 'dtu', :dtu => {:cwis => '1234', :firstname => names[0], :lastname => names[1], :user_type => user_type}})
end
