Feature: Tagging search results and browsing tagged documents

Scenario: Tagging a document in a search result
  Given I'm logged in
    And I search for "A cohomology theory for colored tangles" in the title
    And I add a tag "some tag" to the first document
    And I filter by tag "some tag"
    Then I should see "A cohomology theory for colored tangles"

Scenario: Tagging a document in document view
  Given I'm logged in
    And I search for "A cohomology theory for colored tangles" in the title
    And I click "A cohomology theory for colored tangles"
    And I add a tag "some tag" to the document
    Then I should see "some tag"

Scenario: Removing tag from only document when filtered by same tag
  Given I'm logged in
    And I add a tag "some tag" the document with title "A cohomology theory for colored tangles"
    And I filter by tag "some tag"
    And I remove the tag "some tag" from the first document
   Then I should see 0 documents
