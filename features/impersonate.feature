Feature: Impersonate another user

Background: Existing users
  Given the following DTU employee users exist:
    | identifier | email     | name           | roles          | provider |
    | 1234       | s@upport1 | Support User 1 | "User Support" | cas      |
    | 2345       | s@upport2 | Support User 2 | "User Support" | cas      |
    | 4321       | r@egular  | Regular User   |                | cas      |

Scenario: User with User Support role logs in
  Given I'm logged in as user with identifier "1234"
   Then I should see "Switch user"

Scenario: Users without the User Support role don't see the switch user link
  Given I'm logged in as user with identifier "4321"
   Then I should not see "Switch user"

Scenario: User with User Support role searches for another user to impersonate
  Given I'm logged in as user with identifier "1234"
    And I click "Switch user"
    And I fill in "user_q" with "User"
    And I click "Search for user"
    And I should see "Support User 2" in the list of users
    And I should see "Regular User" in the list of users
    And I should not see "Support User 1" in the list of users

Scenario: Switch to another user 
  Given I'm logged in as user with identifier "1234"
   When I switch user to user with email "r@egular"
   Then the original user should be "Support User 1"
    And the current user should be "Regular User"
    And I should see "Switch back"
    And I should not see "Log out"

Scenario: After switching to another user, the user can switch back to the original user
  Given I've switched user from user with identifier "1234" to user with identifier "4321"
   When I click "Switch back"
   Then the user should be "Support User 1"

Scenario: When switching to another user who has the User Support role, switch user should be disabled
  Given I've switched user from user with identifier "1234" to user with identifier "2345"
   Then I should see "Switch back"
    And I shouldn't see "Switch user"

Scenario: Impersonating an anonymous user
  Given I'm logged in as user with identifier "1234"
    And I click "Switch user"
    And I click "Become anonymous"
   Then the original user should be "Support User 1"
    And the current user should be "Anonymous"
    And I should not see "Log out"
    And I should not see personalized features
    And I should see "Switch back"

Scenario: Impersonating a student user
  Given I'm logged in as user with identifier "1234"
    And I click "Switch user"
    And I click "Become student"
   Then the original user should be "Support User 1"
    And the current user should be "a Student"
    And I should not see "Log out"
    And I should see personalized features
    And I should see "Switch back"

Scenario: Impersonating an employee user
  Given I'm logged in as user with identifier "1234"
    And I click "Switch user"
    And I click "Become employee"
   Then the original user should be "Support User 1"
    And the current user should be "an Employee"
    And I should not see "Log out"
    And I should see personalized features
    And I should see "Switch back"
