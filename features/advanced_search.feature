Feature: Advanced Search

  Scenario: User goes to advanced search page
    Given I go to the root page
     When I click "Advanced search"
     Then I should see the advanced search form
      But I should not see the simple search form

  Scenario: User submits empty advanced search form
    Given I'm on the advanced search page
     When I click "Search"
     Then I should see the advanced search form

  Scenario: User submits filled in advanced search form
    Given I'm on the advanced search page
     When I search for "water" in the "Title" field
     Then I should see the result page
      And I should see "Refine Advanced Search"
    
