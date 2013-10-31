Feature: Request assistance

In order to get the material I'm looking for
As a DTU employee or student
I should be able to request a librarian's assistance in finding the material



Scenario Outline: DTU user views request assistance form
  Given I've logged in as a DTU <user_type>
   When I go to the "request assistance" form for "<genre>"
   Then I should see the "request assistance" form for "<genre>"
    And I should see the "<should_see>" section
    But I shouldn't see the "<should_not_see>" section

Examples:
  | user_type | genre              | should_see        | should_not_see    |
  | employee  | journal article    | physical location | pickup location   |
  | employee  | conference article | physical location | pickup location   |
  | employee  | book               | physical location | pickup location   |
  | student   | journal article    | pickup location   | physical location |
  | student   | conference article | pickup location   | physical location |
  | student   | book               | pickup location   | physical location |



Scenario Outline: Non-DTU user views request assistance form
  Given <login_condition>
   When I go to the "request assistance" form
   Then I should see "Restricted Access (DTU only)"

Examples:
  | login_condition                 |
  | I haven't logged in             |
  | I'm a walk-in user              |
  | I've logged in as a public user |



Scenario Outline: DTU user submits valid request assistance form
  Given I've logged in as a DTU <user_type>
    And I'm on the "request assistance" form for "<genre>"
   When I fill in the "request assistance" form with valid data
    And I click "Send request"
   Then I should see the "request assistance" confirmation page for "<genre>"
    And I should see the "<should_see>" section with the submitted data
    But I shouldn't see the "<should_not_see>" section

Examples:
  | user_type | genre              | should_see        | should_not_see    |
  | employee  | journal article    | physical location | pickup location   |
  | employee  | conference article | physical location | pickup location   |
  | employee  | book               | physical location | pickup location   |
  | student   | journal article    | pickup location   | physical location |
  | student   | conference article | pickup location   | physical location |
  | student   | book               | pickup location   | physical location |



Scenario Outline: DTU user submits invalid request assistance form for journal article
  Given I've logged in as a DTU <user_type>
    And I'm on the "request assistance" form for "journal article"
   When I click "Send request"
   Then I should see the "request assistance" form for "journal article"
    And I should see "One or more required fields are empty"
    And I should see an error in the "Title" field in the "article" form section
    And I should see errors in the "Title", "Volume", "Issue", "Year" and "Pages" fields in the "journal" form section

Examples:
  | user_type |
  | employee  |
  | student   |


Scenario Outline: DTU user submits invalid request assistance form for conference article
  Given I've logged in as a DTU <user_type>
    And I'm on the "request assistance" form for "conference article"
   When I click "Send request"
   Then I should see the "request assistance" form for "conference article"
    And I should see "One or more required fields are empty"
    And I should see an error in the "Title" field in the "article" form section
    And I should see an error in the "Pages" field in the "proceedings" form section
    And I should see errors in the "Title" and "Year" fields in the "conference" form section

Examples:
  | user_type |
  | employee  |
  | student   |



Scenario Outline: DTU user submits invalid request assistance form for book
  Given I've logged in as a DTU <user_type>
    And I'm on the "request assistance" form for "book"
   When I click "Send request"
   Then I should see the "request assistance" form for "book"
    And I should see "One or more required fields are empty"
    And I should see errors in the "Title" and "Year" fields in the "book" form section

Examples:
  | user_type |
  | employee  |
  | student   |



Scenario Outline: DTU user confirms assistance request
  Given I've logged in as a DTU <user_type>
    And I've submitted a valid assistance request for "<genre>"
   When I click "Confirm request"
   Then I should see "Your request was sent to a librarian"
    And I should see the submitted data
    And I should see the "<should_see>" section with the submitted data
    But I should not see the "<should_not_see>" section

Examples:
  | user_type | genre              | should_see        | should_not_see    |
  | employee  | journal article    | physical location | pickup location   |
  | employee  | conference article | physical location | pickup location   |
  | employee  | book               | physical location | pickup location   |
  | student   | journal article    | pickup location   | physical location |
  | student   | conference article | pickup location   | physical location |
  | student   | book               | pickup location   | physical location |
