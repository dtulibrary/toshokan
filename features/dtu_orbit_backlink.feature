Feature: DTU ORBIT backlink

Scenario: DTU ORBIT backlinks don't appear in search results
  Given I'm logged in
  When I search for "source_ss:orbit"
  Then I should see one or more documents
   But I should not see any DTU ORBIT backlinks

Scenario: DTU ORBIT backlinks appear in detail view
 Given I'm logged in
  When I search for "source_ss:orbit"
   And I click on the first document
  Then I should see a DTU ORBIT backlink
