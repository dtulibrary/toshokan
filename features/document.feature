Feature: Show a single document

Scenario: User wants to see the details for a single record
  Given I'm logged in as user with no role
	And I have searched for "*:*"	
   When I click on the title for the first of the results
   Then I should see the page for a single document