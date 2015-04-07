Feature: View forms

DTU users can view "request assistance" forms.
Other users can see the DTU Library Corporate Service.

Scenario Outline: DTU user goes to a request form
  Given I'm logged in as a DTU <user_type>
   When I go to the "request assistance" form for "<genre>"
   Then I should see the "request assistance" form for "<genre>"

Examples:
  | user_type | genre              |
  | employee  | journal article    |
  | employee  | conference article |
  | employee  | book               |
  | employee  | thesis             |
  | employee  | report             |
  | employee  | standard           |
  | employee  | patent             |
  | employee  | other              |
  | student   | journal article    |
  | student   | conference article |
  | student   | book               |
  | student   | thesis             |
  | student   | report             |
  | student   | standard           |
  | student   | patent             |
  | student   | other              |

Scenario Outline: Other authenticated user goes to a request form
  Given I'm logged in as a <user_type>
   When I go to the "request assistance" form for "<genre>"
   Then I should see "Need help from a DTU librarian?"
    But I shouldn't see a "request assistance" form

Examples:
  | user_type   | genre              |
  | DTU guest   | journal article    |
  | DTU guest   | conference article |
  | DTU guest   | book               |
  | DTU guest   | thesis             |
  | DTU guest   | report             |
  | DTU guest   | standard           |
  | DTU guest   | patent             |
  | DTU guest   | other              |
  | public user | journal article    |
  | public user | conference article |
  | public user | book               |
  | public user | thesis             |
  | public user | report             |
  | public user | standard           |
  | public user | patent             |
  | public user | other              |

Scenario Outline: Anonymous user goes to a request form
  Given I'm <user_type>
   When I go to the "request assistance" form for "<genre>"
   Then I should see "Need help from a DTU librarian?"
    But I shouldn't see a "request assistance" form

Examples:
  | user_type         | genre              |
  | a walk-in user    | journal article    |
  | a walk-in user    | conference article |
  | a walk-in user    | book               |
  | a walk-in user    | thesis             |
  | a walk-in user    | report             |
  | a walk-in user    | standard           |
  | a walk-in user    | patent             |
  | a walk-in user    | other              |
  | an anonymous user | journal article    |
  | an anonymous user | conference article |
  | an anonymous user | book               |
  | an anonymous user | thesis             |
  | an anonymous user | report             |
  | an anonymous user | standard           |
  | an anonymous user | patent             |
  | an anonymous user | other              |
