Feature: Search history

As a user my search history is saved

Scenario: The temporary search history is added to the permanent history when logging in
    Given I go to the root page
      And I search for "testing"
      And I search for "more test"
      And I log in
      And I go to the search history
     Then I should see "testing" in the history
      And I should see "more test" in the history

Scenario: Limits are visible in search history
    Given I'm logged in as a DTU employee
     When I search for "Sprawozdanie 2008 Grabowski"
      And I click on the first document
      And I click "Find other material by Grabowski, Marcin"
      And I go to the search history
     Then I should see a constraint with name "Author" and value "Grabowski, Marcin"
