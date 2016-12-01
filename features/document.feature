Feature: Show a single document

Background:
  Given I'm logged in as a DTU employee

Scenario: User wants to see the details for a single record
  When I have searched for "A Codebook Design Method for Robust VQ-Based Face Recognition Algorithm"
   And I click on the first document	  
  Then I should see the page for a single document
   And I should see the "Authors", "Journal", "Type", "ISSN" and "DOI" fields

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
  When I have searched for "mechanics"
   And I have limited the "Type" facet to "Journal"
   And I click on the first document
  Then I should not see the "Export to BibTeX" link 
   And I should not see the "Export to RIS" link

Scenario: View patent keywords
When I go to the record page for "Omni rotational driving and steering wheel"
Then I should see "steering wheel modul"

Scenario: View patent abstract
When I go to the record page for "Omni rotational driving and steering wheel"
Then I should see "Abstract of WO 2008138346  (A1) There is disclosed a driving and steering wheel"

Scenario: View patent affiliations
When I go to the record page for "Omni rotational driving and steering wheel"
Then I should see "Department of Industrial and Civil Engineering, Faculty of Engineering, SDU"
Then I should see "Faculty of Engineering, SDU"
Then I should see "Institute of Chemical Engineering, Biotechnology and Environmental Technology, Faculty of Engineering, SDU"
Then I should see "Institute of Technology and Innovation, Faculty of Engineering, SDU"

Scenario: View patent language
When I go to the record page for "Apparatus for loading and unloading a cargo compartment of an aircraft"
Then I should see "Language: English"

Scenario: View patent doctype
When I go to the record page for "177-Lu labeled peptide for site-specific uPAR-targeting"
Then I should see "Types: Other (Patent)"

Scenario: View Journal Subtitle
  When I go to the record page for "Talent among Chinese Entrepreneurs at Home and Abroad"
  Then I should see "New Horizons in Management"
