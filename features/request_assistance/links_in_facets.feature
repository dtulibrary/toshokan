Feature: Links in facets

When DTU employee or student searches and gets result,
There should be links to the request assistance forms
for journal article, conference article and book in the
left side menu.

Other users should not see these links.

Scenario Outline: DTU employee or student gets one or more hits
  Given I'm logged in as a DTU <user_type>
   When I search for something that gives one or more hits
   Then I <should_form> see a link to the "request assistance" form for "<genre>" in the left menu

Examples:
  | user_type | genre              | should_form |
  | employee  | journal article    | should      |
  | employee  | conference article | should      |
  | employee  | book               | should      |
  | employee  | thesis             | should not  |
  | employee  | report             | should not  |
  | employee  | standard           | should not  |
  | employee  | patent             | should not  |
  | employee  | other              | should not  |
  | student   | journal article    | should      |
  | student   | conference article | should      |
  | student   | book               | should      |
  | student   | thesis             | should not  |
  | student   | report             | should not  |
  | student   | standard           | should not  |
  | student   | patent             | should not  |
  | student   | other              | should not  |

Scenario Outline: Other user gets one or more hits
  Given I'm <user_type>
   When I search for something that gives one or more hits
   Then I should not see any links to the "request assistance" forms in the left menu

Examples:
  | user_type                  |
  | logged in as a DTU guest   |
  | logged in as a public user |
  | an anonymous user          |
  | a walk-in user             |
