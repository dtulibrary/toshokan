Feature: Manage Users
  In order to grant/revoke access to restricted functionality for any user
  As an admin user
  I should be able to assign/remove any role to/from any user.

  Background:
    Given the following DTU employee users exist:
      | identifier | email     | name           | roles           | provider |
      | 1234       | s@upport1 | Admin User     | "Administrator" | cas      |
      | 4321       | r@egular  | Regular User   |                 | cas      |
      
      And I'm logged in as user with identifier "1234"
      And I'm on the user management page

  Scenario: Admin assigns role to an existing user
    When I add role "User Support" to user with identifier "4321"
     And I save user with identifier "4321"
    Then I should be on the user management page
     And the user with identifier "4321" should have role "User Support"

  Scenario: Admin removes role from an existing user
    Given user with identifier "4321" has role "User Support"
     When I remove role "User Support" from user with identifier "4321"
      And I save user with identifier "4321"
     Then I should be on the user management page
      And the user with identifier "4321" should not have role "User Support"


