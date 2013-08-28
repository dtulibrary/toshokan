Feature: Non-DTU user views forms

When a user who is not authenticated as either a DTU employee
or a DTU student views the forms, no forms should be displayed.
Instead info about and link to DTU Corporate Service should be 
displayed

Scenario Outline: Following links to forms
  Given <login_condition>
    And I've searched for "kjashdkajshd kjahskjah"
   When I click the link "<link>"
   Then I should see <should_see>
    But I shouldn't see <should_not_see>

Examples:
  | login_condition                | link                | should_see                      | should_not_see                               |
  | I'm logged in as a public user | Journal article     | "DTU Library Corporate service" | the "can't find" form for journal article    |
  | I'm a walk-in user             | Conference article  | "DTU Library Corporate service" | the "can't find" form for conference article |
  | I haven't logged in            | Book                | "DTU Library Corporate service" | the "can't find" form for book               |
