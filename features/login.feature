
Feature: Login and logout

Scenario: User logs in and out
  Given I'm logged in
  And I log out
  Then I should see "Log in"

Scenario: Public user logs in
  Given I'm logged in as a public user with email "somebody@example.com"
  Then I should see "somebody@example.com"

Scenario: DTU employee logs in
  Given I'm logged in as a DTU employee with name "Firstname Lastname"
  Then I should see "Firstname Lastname"