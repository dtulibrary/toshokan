Feature: Tagging search results and browsing tagged documents

Background:
  Given I'm logged in

Scenario: Documents should by default not be bookmarked or tagged
    When I search for "cohomology"
    Then the first document should not be bookmarked
     And the first document should not have tags

Scenario: Bookmarking a document in a search result
    When I search for "cohomology"
     And I bookmark the first document
    Then the first document should be bookmarked

Scenario: Un-bookmark a document in a search result
    When I bookmark the document with title "A cohomology theory for colored tangles"
     And I search for "title:(cohomology colored tangles)"
     And I unbookmark the first document
    Then the first document should not be bookmarked

Scenario: Bookmarking a document in document view
    When I go to the record page for "A cohomology theory for colored tangles"
     And I bookmark the document
    Then the document should be bookmarked

Scenario: Filtering by "All" should list bookmarked documents
    When I bookmark the document with title "A cohomology theory for colored tangles"
     And I filter by tag "All"
    Then I should see "A cohomology theory for colored tangles"

# Scenario: Bookmark constraints should be displayed in search history
#     When I bookmark the document with title "A cohomology theory for colored tangles"
#      And I filter by tag "All"
#      And I go to the search history
#     Then I should see a constraint with name "Bookmarks:" and value "All"

# Scenario: Bookmark constraints should be displayed in search history
#     When I bookmark the document with title "A cohomology theory for colored tangles"
#      And I filter by tag "Untagged"
#      And I go to the search history
#     Then I should see a constraint with name "Bookmarks:" and value "Untagged"

Scenario: Bookmark constraints should be displayed above the search result
    When I bookmark the document with title "A cohomology theory for colored tangles"
     And I filter by tag "All"     
    Then I should see a tag constraint with name "Bookmarks" and value "All"

Scenario: Bookmark constraints should be displayed above the search result
    When I bookmark the document with title "A cohomology theory for colored tangles"
     And I filter by tag "Untagged"
    Then I should see a tag constraint with name "Bookmarks" and value "Untagged"

Scenario: Un-bookmark a document in document view
    When I bookmark the document with title "A cohomology theory for colored tangles"
     And I go to the record page for "A cohomology theory for colored tangles"
     And I unbookmark the document
    Then the document should not be bookmarked

Scenario: Tagging a document in a search result
   When I search for "title:(A cohomology theory for colored tangles)"
    And I add a tag "some tag" to the first document
    And I filter by tag "some tag"
   Then I should see "A cohomology theory for colored tangles"
    And the first document should have tags

Scenario: Tagging a document in document view
   When I go to the record page for "A cohomology theory for colored tangles"
    And I add a tag "some tag" to the document
   Then the document should be tagged with "some tag"

Scenario: Removing tag from a document in document view
   When I add a tag "some tag" to the document with title "A cohomology theory for colored tangles"
    And I filter by tag "some tag"
    And I click the link "A cohomology theory for colored tangles"
    And I remove the tag "some tag" from the document
   Then the document should not be tagged with "some tag"

Scenario: Removing tag from only tagged document and filtering by same tag
   When I add a tag "some tag" to the document with title "A cohomology theory for colored tangles"
    And I filter by tag "some tag"
    And I remove the tag "some tag" from the first document
    And I reload the page
   Then I should see 0 documents

# Scenario: Tag constraints should be displayed in search history
#    When I add a tag "some tag" to the document with title "A cohomology theory for colored tangles"
#     And I filter by tag "some tag"
#     And I go to the search history
#    Then I should see a constraint with name "Tagged:" and value "some tag"

Scenario: Tag constraints should be displayed above the search result
   When I add a tag "some tag" to the document with title "A cohomology theory for colored tangles"
    And I filter by tag "some tag"
   Then I should see a tag constraint with name "Tagged" and value "some tag"

