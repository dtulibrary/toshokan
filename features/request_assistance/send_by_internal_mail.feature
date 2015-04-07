Feature: Send by DTU internal mail

DTU employees can select to have material sent by DTU internal mail.
Patents are are handled by delegating mail correspondance to PatLib
so those should not have a physical delivery section.

DTU students should not see the option to have material sent by 
DTU internal mail.

Scenario Outline: DTU employee views request assistance form
  Given I've logged in as a DTU <user_type>
   When I go to the "request assistance" form for "<genre>"
   Then I <should_form> see the deliver by internal mail option in the "physical delivery" section

Examples:
  | user_type | genre              | should_form |
  | employee  | journal article    | should      |
  | employee  | conference article | should      |
  | employee  | book               | should      |
  | employee  | thesis             | should      |
  | employee  | report             | should      |
  | employee  | standard           | should      |
  | employee  | patent             | should not  |
  | employee  | other              | should      |
  | student   | journal article    | should not  |
  | student   | conference article | should not  |
  | student   | book               | should not  |
  | student   | thesis             | should not  |
  | student   | report             | should not  |
  | student   | standard           | should not  |
  | student   | patent             | should not  |
  | student   | other              | should not  |

Scenario Outline: DTU employee submits request assistance form
  Given I've logged in as a DTU employee
   When I fill out a valid "request assistance" form for "<genre>"
    And I select physical delivery "Send by DTU Internal Mail"
    And I submit the form
    And I decline any resolver results
   Then I should see the confirmation page
    And I should see physical delivery to my DTU address

Examples:
  | genre              |
  | journal article    |
  | conference article |
  | book               |
  | thesis             |
  | report             |
  | standard           |
  | other              |
