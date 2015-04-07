Feature: Confirm forms

DTU employees and students can confirm the request assistance forms,
creating the request and sending them to the order status page

Scenario Outline: DTU user a submitted request assistance form
  Given I'm logged in as a DTU <user_type>
    And I've submitted a valid "request assistance" form for "<genre>"
   When I confirm the form submission
   Then I should see the order status page

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
