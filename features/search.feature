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
