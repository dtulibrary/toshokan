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

Scenario Outline: User does a zero-hit search
 Given <login_condition>
   And I'm on the search page
  When I search for "sdjkfhskdjfhskdjfh"
  Then I should see the no hits page
   And I <should_form> see the "request assistance" form links
 
Examples:
  | login_condition                  | should_form |
  | I haven't logged in              | should not  |
  | I'm a walk-in user               | should not  |
  | I've logged in as a public user  | should not  |
  | I've logged in as a DTU employee | should      |
  | I've logged in as a DTU student  | should      |

Scenario Outline: "Can't find it?" links are only visible to DTU employes and DTU students
  Given <login_condition>
    And I'm on the search page
   When I search for "*:*"
   Then I should see the result page
    And I <should_form> see the "can't find it?" links

Examples:
  | login_condition                  | should_form |
  | I haven't logged in              | should not  |
  | I'm a walk-in user               | should not  |
  | I've logged in as a public user  | should not  |
  | I've logged in as a DTU employee | should      |
  | I've logged in as a DTU student  | should      |

Scenario: "Can't find it?" links are only visible when hits > 0
  Given I'm logged in as a DTU employee
   When I search for "sdkjfhskdjfhskdjfhkjh"
   Then I should see the result page
    But I shouldn't see the "can't find it?" links

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
