Feature: Impersonate another user

Background: Existing users
  Given the following DTU employee users exist:
    | identifier | email     | name           | roles          | provider |
    | 1234       | s@upport1 | Support User 1 | "User Support" | cas      |
    | 2345       | s@upport2 | Support User 2 | "User Support" | cas      |
    | 4321       | r@egular  | Regular User   |                | cas      |

Scenario: User with User Support role logs in
  Given I'm logged in as user with identifier "1234"
   Then I should see "Switch User"

Scenario: Switch to another user 
  Given I'm logged in as user with identifier "1234"
   When I switch user to user with identifier "4321"
   Then the user should be "Regular User"
    And I should see "Switch Back"

Scenario: Users without the "User Support" role don't see the switch user link
  Given I'm logged in as user with identifier "4321"
   Then I should not see "Switch User"
  
Scenario: After having switched to another user, the user can switch back to the original user
  Given I've switched user from user with identifier "1234" to user with identifier "4321"
   When I click "Switch Back"
   Then the user should be "Support User 1"

Scenario: When switching to another user who has the "User Support" role, switch user should be disabled
  Given I've switched user from user with identifier "1234" to user with identifier "2345"
   Then I should see "Switch Back"
    And I shouldn't see "Switch User"
