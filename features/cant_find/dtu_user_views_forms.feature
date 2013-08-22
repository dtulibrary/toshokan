Feature: DTU user views forms

When on a zero-hit result page, DTU users can see and follow
the "Journal article", "Conference article" and "Book" 
to the corresponding "can't find" forms.

Scenario Outline: Only DTU users can see links to "can't find" form
  Given <condition>
    And I'm on the search page
   When I search for "sdkjfhaksdjfhasdkfjhasdkfj"
   Then I <should_form> see the "can't find" form links

Examples:
   | condition                      | should_form |   
   | I haven't logged in            | shouldn't   |
   | I'm a walk-in user             | shouldn't   |
   | I'm logged in as a DTU user    | should      |   

Scenario Outline: Following links to forms
  Given I'm logged in as a DTU user
    And I've searched for "kjashdkajshd kjahskjah"
   When I click the link "<link>"
   Then I should see the "can't find" form for <genre>

Examples:
  | link               | genre              |
  | Journal article    | journal article    |
  | Conference article | conference article |
  | Book               | book               |
