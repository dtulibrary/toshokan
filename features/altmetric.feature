Feature: Altmetric

Scenario: Altmetric badge doesn't appear in search results
  Given I'm logged in
  When I search for "Self-assembly of short DNA duplexes: from a coarse-grained model to experiments through a theoretical link"
  Then I should not see the altmetric badge for doi "10.1039/C2SM25845E"

Scenario: Altmetric badge appears in detail view
 Given I'm logged in
  When I search for "Self-assembly of short DNA duplexes: from a coarse-grained model to experiments through a theoretical link"
   And I click on the first document
  Then I should see the altmetric badge for doi "10.1039/C2SM25845E"
