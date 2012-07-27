Feature: Tagging search results and browsing tagged documents

Scenario: Tagging a document in a search result
  Given I'm logged in
    And I search for "A cohomology theory for colored tangles" in the title
    And I add a tag "some tag" to the first document
    And I browse the tag "some tag"
    And I click the link "366872642"
    #Then I should see a document with title "A cohomology theory for colored tangles"
    Then I should see "A cohomology theory for colored tangles"
