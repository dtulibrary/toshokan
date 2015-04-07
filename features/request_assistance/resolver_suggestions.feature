Feature: Resolver suggestions

When a DTU employee or student submits a request assistance form,
A search is performed in the catalog to see if there should be one
or more matching records.

If there are matching records, the user is taken to the catalog page
with the option to decline the result and go to the request assistance
confirmation page.

If there are no matching records, the user is taken directly to the
request assistance confirmation page.
 
Background: DTU employee
  Given I've logged in as a DTU employee

Scenario: One or more matching records
  Given I'm on the "request assistance" form for "other"
   When I fill in "Title" in the "Other" form section with "water"
    And I fill in "Year" in the "Host" form section with "2010"
    And I submit the form
   Then I should see the search result page
    And I should see the resolver suggestions

Scenario: Declining the resolver suggestions
  Given I've submitted a valid "request assistance" form for "other"
   When I decline any resolver results
   Then I should see the "request assistance" confirmation page for "other"

Scenario: No matching records
  Given I've filled out a valid "request assistance" form for "journal article"
   When I submit the form
   Then I should see the "request assistance" confirmation page for "journal article"
