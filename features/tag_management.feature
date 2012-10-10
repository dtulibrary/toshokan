Feature: Tag management

As a user utilizing tags to organize my saved documents I want to be able to
list, rename, and delete my tags

Scenario: Listing all tags
  Given I'm logged in
    And I add a tag "some tag" the document with title "A cohomology theory for colored tangles"
    And I list my tags
   Then I should see "some tag"

 Scenario: Rename a tag
  Given I'm logged in
    And I add a tag "some tag" the document with title "A cohomology theory for colored tangles"
    And I rename tag "some tag" to "some other tag"
   Then I should see "some other tag"

 Scenario: Delete a tag
  Given I'm logged in
    And I add a tag "some tag" the document with title "A cohomology theory for colored tangles"
    And I delete tag "some tag"
   Then I should not see "some tag"
