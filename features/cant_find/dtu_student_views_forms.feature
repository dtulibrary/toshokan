Feature: DTU student views forms

When a DTU student views the "can't find" forms, in addition
to seeing the appropriate form given a genre, he
should also be presented with the option to select a pick-up
location from "Lyngby" or "Ballerup".

Scenario Outline: Following links to forms
  Given I'm logged in as a DTU student
    And I've searched for "kjashdkajshd kjahskjah"
   When I click the link "<link>"
   Then I should see <should_see>
    And I should see "Pick-up location"
    But I shouldn't see <should_not_see>

Examples:
  | link                                          | should_see                                   | should_not_see                  |
  | Contact librarian to order journal article    | the "can't find" form for journal article    | "DTU Library Corporate service" |
  | Contact librarian to order conference article | the "can't find" form for conference article | "DTU Library Corporate service" |
  | Contact librarian to order book               | the "can't find" form for book               | "DTU Library Corporate service" |
