#@javascript
Feature: Tagging search results and browsing tagged documents

Scenario: Tagging a document in a search result
  Given I'm logged in
    And I search for "A cohomology theory for colored tangles" in the title
    And I add a tag "some tag" to the first document
    And I filter by tag "some tag"
    Then I should see "A cohomology theory for colored tangles"
     And I should see the first document as bookmarked
     And I should see "some tag" on the first document

Scenario: Tagging a document in document view
  Given I'm logged in
    And I search for "A cohomology theory for colored tangles" in the title
    And I click the link "A cohomology theory for colored tangles"
    And I add a tag "some tag" to the document
    Then I should see "some tag" on the document

Scenario: Removing tag from a document in document view
  Given I'm logged in
    And I add a tag "some tag" to the document with title "A cohomology theory for colored tangles"
    And I filter by tag "some tag"
    And I click the link "A cohomology theory for colored tangles"
    And I remove the tag "some tag" from the document
    Then I should not see "some tag" on the document

Scenario: Removing tag from a document and filtering by same tag
  Given I'm logged in
    And I add a tag "some tag" to the document with title "A cohomology theory for colored tangles"
    And I filter by tag "some tag"
    And I remove the tag "some tag" from the first document
    And I reload the page
    Then I should see 0 documents