Feature: Any user can see "can't find" links

When on a zero-hit result page, any user can see
the "can't find" links.

Scenario Outline: User can see links to "can't find" form
  Given <login_condition>
    And I'm on the search page
   When I search for "sdkjfhaksdjfhasdkfjhasdkfj"
   Then I should see the "can't find" form links

Examples:
   | login_condition                 |   
   | I haven't logged in             |   
   | I'm a walk-in user              |   
   | I'm logged in as a DTU employee |
   | I'm logged in as a DTU student  |
   | I'm logged in as a public user  |
