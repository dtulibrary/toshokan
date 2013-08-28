Feature: DTU employee views forms

Scenario Outline: Following links to forms
  Given I'm logged in as a DTU employee
    And I've searched for "kjashdkajshd kjahskjah"
   When I click the link "<link>"
   Then I should see <should_see>
    And I should see "Physical location"
    But I shouldn't see <should_not_see>

Examples:
  | link               | should_see                                   | should_not_see                  |
  | Journal article    | the "can't find" form for journal article    | "DTU Library Corporate service" |
  | Conference article | the "can't find" form for conference article | "DTU Library Corporate service" |
  | Book               | the "can't find" form for book               | "DTU Library Corporate service" |
