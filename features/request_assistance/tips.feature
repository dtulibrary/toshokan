@wip
Feature: Tips

When a user views the request assistance forms
he should see some tips on where he might go to
find what he is looking for.

The tips should be differentiated on the type of
request and whether the user came to a pre-filled
form or a blank form.

Scenario Outline: DTU User views a blank request assistance form
  Given I'm logged in as a DTU <user_type>
   When I go to the "request assistance" form for "<genre>"
   Then I should see the "<genre>" tips

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
