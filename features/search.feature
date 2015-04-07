Feature: Search

Scenario Outline: User search for something
  Given I'm logged in
   When I search for "<query>"
   Then I should see the result page
    And I should see <results> documents

Examples:
	| query    | results |
	| *:*	     | 10      |
	| dlasjdkl | 0       |

Scenario: User does a zero-hit search
 Given I'm logged in
   And I'm on the search page
  When I search for "sdjkfhskdjfhskdjfh"
  Then I should see the no hits page

Scenario: Export result in BibTex format
  Given I'm logged in as a DTU employee
   When I search for "integer"
   And I click "Export to BibTeX"
  Then I should get a "bib" file

Scenario: Export result in RIS format
  Given I'm logged in as a DTU employee
   When I search for "integer"
   And I click "Export to RIS"
  Then I should get a "ris" file
