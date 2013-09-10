Feature: Order/request article scan from external supplier or local holdings

Scenario: Anonymous user should see order form with empty email
  Given I go to the root page
  Given I search for "A cohomology theory for colored tangles"
    And I click "Get it"
    And I click "Order now"
    And the "email" field should be blank

Scenario: Authenticated DTU user should see order form with pre-filled email
  Given I'm logged in as a DTU employee with email "somebody@example.com" and name "Firstname Lastname"
    And I search for "A cohomology theory for colored tangles"
    And I click "Get it"
    And I click "Order now"
    And the "email" field should contain "somebody@example.com"
