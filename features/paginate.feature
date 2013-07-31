Feature: Paginate search results

  In order to browse through the entire search result
  As a user
  I should see pagination on the search result

  Background: User is logged in
    Given I'm logged in

  Scenario: A result set that fits on one page
    When I search for "title:(water resources bulletin)"
    Then I should not see any pagination

  Scenario: A result set that fits within the inner window of the pagination
    When I search for "technology"
    Then I should see page links from 1 to 5
    And  the next page link should be active
    But  the previous page link should be inactive
    And  I should not see any page gaps

  Scenario: A result set that doesn't fit within the inner window of the pagination
    When I search for "*"
    Then I should see page links from 1 to 5
    And  I should see the forward page gap
    And  the next page link should be active
    But  the previous page link should be inactive

  Scenario: Moving into a result set that fits within the inner window of the pagination
    When I search for "technology"
    And  I go to the next page of the result set
    Then I should see page links from 1 to 5
    And  the next page link should be active
    And  the previous page link should be active
    But  I should not see any page gaps

  Scenario: Moving into a result set that doesn't fit within the inner window of the pagination
    When I search for "*"
    And  I go to page 5 of the result set
    And  I go to the next page of the result set
    Then I should see page links from 2 to 10
    And  the next page link should be active
    And  the previous page link should be active
    And  I should see both page gaps

