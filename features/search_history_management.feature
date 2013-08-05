Feature: Search history management

As a logged in user I can see my search history, and save and add alerts on searches

Background:
  Given I'm logged in
    And I search for "test"
    And I go to the search history

Scenario: A search is added to the permanent history when logged in  
   Then I should see "test" in the history

Scenario: A search can be save
   When I save the search "test"  
   Then it should be saved   

Scenario: A search can be unsaved
  When I save the search "test"
   And I unsave the search "test"
  Then it should not be saved

Scenario: A search can be alerted
  When I alert the search "test"
  Then it should be alerted

Scenario: A search alert can be removed from a search
  When I alert the search "test"
   And I remove the alert from the search "test"    
  Then it should not be alerted  

Scenario: A search can be deleted from the search history
  When I delete the search "test"
  Then I should not see "test" in the history
