Feature: Show metrics for a single document

Background:
  Given I'm logged in as a DTU employee

@javascript
Scenario: User wants to see the citation count for a single record
  When I go to the record page for "365 DAYS: 2011 in review"
   And Wait for AJAX requests to finish
  Then I should see "Citation count"
