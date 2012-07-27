Feature: Search

Scenario Outline: User search for something
  Given I'm logged in as user with no role
   When I search for "<query>"
   Then I should see the result page
    And I should see <results> results

Examples:
	| query    | results |
	| *:*	     | 10      |
	| dlasjdkl | 0       |
