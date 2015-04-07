Feature: Links on zero-hit page

When DTU employee or student searches and gets zero hits, 
he should be presented with links to the journal article, 
conference article, book, thesis, report, standard and 
patent request forms.

Other users should not see any links to request forms.

Scenario Outline: DTU employee or student gets zero hits
  Given I'm logged in as a DTU <user_type>
   When I search for something that gives zero hits
   Then I <should_form> see a link to the "request assistance" form for "<genre>"

Examples:
  | user_type | genre              | should_form |
  | employee  | journal article    | should      |
  | employee  | conference article | should      |
  | employee  | book               | should      |
  | employee  | thesis             | should      |
  | employee  | report             | should      |
  | employee  | standard           | should      |
  | employee  | patent             | should      |
  | employee  | other              | should not  |
  | student   | journal article    | should      |
  | student   | conference article | should      |
  | student   | book               | should      |
  | student   | thesis             | should      |
  | student   | report             | should      |
  | student   | standard           | should      |
  | student   | patent             | should      |
  | student   | other              | should not  |

Scenario Outline: Other user gets zero hits
  Given I'm <user_type>
   When I search for something that gives zero hits
   Then I shouldn't see any links to the "request assistance" forms

Examples:
  | user_type                  |
  | logged in as a DTU guest   |
  | logged in as a public user |
  | an anonymous user          |
  | a walk-in user             |
