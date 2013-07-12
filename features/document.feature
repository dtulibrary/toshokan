Feature: Show a single document

Background:
       Given I'm logged in as a DTU employee

Scenario: User wants to see the details for a single record
	 When I have searched for "A Codebook Design Method for Robust VQ-Based Face Recognition Algorithm"
	  And I click on the first document	  
         Then I should see the page for a single document

Scenario: Export record in BibTex format
        When I go to the record page for "A Codebook Design Method for Robust VQ-Based Face Recognition Algorithm"
         And I click "Export to BibTeX"
        Then I should get a "bib" file

Scenario: Export record in RIS format
        When I go to the record page for "A Codebook Design Method for Robust VQ-Based Face Recognition Algorithm"
         And I click "Export to RIS"
        Then I should get a "ris" file

 Scenario: View citations
 	When I go to the record page for "A Codebook Design Method for Robust VQ-Based Face Recognition Algorithm"
 	 And I click "Cite"
 	Then I should see the citations

Scenario: Do not export a record for a journal
	 When I have searched for "Photochemistry and photobiology"
	  And I have limited the "Type" facet to "Journal"
	  And I click the link for journal "Photochemistry and photobiology"
	 Then I should not see the "Export to BibTeX" link 
	  And I should not see the "Export to RIS" link
