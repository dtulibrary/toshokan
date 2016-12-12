Feature: Query and filters are visible on "show document" page.

When a user clicks to single document view (the show document page)
from a search result, the query and any filters should still be
visible in the search form.

Scenario: User clicks on a document from the search result
  Given I've searched for "water"
    And I've limited the "Types" facet to "Article (Journal article)"
   When I click on the first document
   Then I should see the search form filled with "water"
    And the "Types" facet should be constrained to "Article (Journal article)"
    But I shouldn't see any links to remove the constraint
