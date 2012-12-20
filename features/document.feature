Feature: Show a single document

Scenario: User wants to see the details for a single record
	Given I'm logged in
	  And I have searched for "A Codebook Design Method for Robust VQ-Based Face Recognition Algorithm"
	  And I click the link "A Codebook Design Method for Robust VQ-Based Face Recognition Algorithm"
   Then I should see the page for a single document

Scenario: Export record in BibTex format
	Given I go to the record page for "A Codebook Design Method for Robust VQ-Based Face Recognition Algorithm"
	  And I click "Export to BibTeX"
	 Then I should get a "bib" file

Scenario: Export record in RIS format
	Given I go to the record page for "A Codebook Design Method for Robust VQ-Based Face Recognition Algorithm"
	Given I click "Export to RIS"
	Then I should get a "ris" file

 Scenario: View citations
 	Given I go to the record page for "A Codebook Design Method for Robust VQ-Based Face Recognition Algorithm"
 	Given I click "Cite"
 	Then I should see the citations

Scenario: Do not export a record for a journal
	Given I'm logged in
	  And I have searched for "Photochemistry and photobiology"
	  And I have the limited the "Format" facet to "journal"
	  And I click the link "Photochemistry and photobiology"
	 Then I should not see the "Export to BibTeX" link
	  And I should not see the "Export to RIS" link
