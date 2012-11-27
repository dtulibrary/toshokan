@wip
Feature: Paginate search results

  In order to browse through the entire search result
  As a user
  I should see pagination on the search result

  Background: User is logged in
    Given I'm logged in

  Scenario: A result set that fits on one page
    When I search for "water resources bulletin" in the "Title" field
    Then I should not see any pagination

  Scenario: A result set that fits within the inner window of the pagination
    When I search for "technology"
    Then I should see 5 page links
    And  I should see the next page link
    But  I should not see the previous page link
    And  I should not see any page gaps

  Scenario: A result set that doesn't fit within the inner window of the pagination
    When I search for "*"
    Then I should see 5 page links
    And  I should see the next page link
    And  I should see the forward page gap
    But  I should not see the previous page link
    And  I should not see the backward page gap

  Scenario: Moving into a result set that fits within the inner window of the pagination
    When I search for "technology"
    And  I go to the next page of the result set
    Then I should see 5 page links
    And  I should see the previous page link
    And  I should see the next page link
    But  I should not see any page gaps

  Scenario: Moving into a result set that doesn't fit within the inner window of the pagination
    When I search for "*"
    And  I go to page 5 of the result set
    And  I go to the next page of the result set
    Then I should see 9 page links
    And  I should see the previous page link
    And  I should see the next page link
    And  I should see both page gaps

