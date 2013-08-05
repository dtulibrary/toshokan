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
