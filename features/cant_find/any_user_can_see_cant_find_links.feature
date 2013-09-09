Feature: All users can see "can't find" links. Wording is different for DTU users.

When on a zero-hit result page, public and anonymous users
can see the "can't find" help links. DTU users can see the "can't find"
form links (i.e. links explicitly mention staff assistance)


Scenario Outline: User can see links to "can't find" help page
  Given <login_condition>
    And I'm on the search page
   When I search for "sdkjfhaksdjfhasdkfjhasdkfj"
   Then I should see the "can't find" help links

Examples:
   | login_condition                 |
   | I haven't logged in             |
   | I'm a walk-in user              |
   | I'm logged in as a public user  |


Scenario Outline: User can see links to "can't find" form
  Given <login_condition>
    And I'm on the search page
   When I search for "sdkjfhaksdjfhasdkfjhasdkfj"
   Then I should see the "can't find" form links

Examples:
   | login_condition                 |
   | I'm logged in as a DTU employee |
   | I'm logged in as a DTU student  |
