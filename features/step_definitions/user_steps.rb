# encoding: utf-8

Given /^I(?:'ve not| have(?: not|n't)) logged in$/ do
  # For narrative purposes in features
end

Given /^I(?:'ve| have) logged in(.*)$/ do |m|
  step %{I'm logged in#{m}}
end

Then /^the(?: current)? user should be "(.*?)"$/ do |username|
  find('#util-links #current-user').should have_content username
end

Given /^the following DTU employee users? exists?:$/ do |table|
  table.map_column!('roles') { |roles| roles.scan(/"(.*?)"/).flatten }
  table.hashes.each do |hash|
    hash['name'] ||= 'John Doe'

    user = mock_dtu_user(hash['identifier'], hash['email'], 'dtu_empl', hash['name'])
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

Given /^I'm logged in as a DTU (user|employee|student|guest) with name "([^\"]*?)"$/ do |arg1, arg2|
  log_in(mock_dtu_user('12345678', 'fake.email@example.com', arg1, arg2))
end

Given /^I'm logged in as a DTU (user|employee|student|guest) with email "(.*?)" and name "(.*?)"$/ do |arg1, arg2, arg3|
  log_in(mock_dtu_user('12345678', arg2, arg1, arg3))
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

  @current_user = user
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
  user_type = 'dtu_empl' if user_type == 'employee'
  mock_user(identifier, email, {
    :provider => 'dtu', 
    :dtu => {
      :cwis => '1234', 
      :firstname => names[0], 
      :lastname => names[1], 
      :user_type => user_type,
      :org_units => ['58']
    },
    :address => {
      :line1 => 'Address line 1',
      :line2 => 'Address line 2',
      :line3 => 'Address line 3',
      :line4 => 'Address line 4',
      :line5 => 'Address line 5',
      :line6 => 'Address line 6',
      :zipcode => 'ZIP',
      :cityname => 'City',
      :country => 'Country'
    }
  })
end
