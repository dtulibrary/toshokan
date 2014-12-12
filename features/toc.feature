Feature: Show and navigate ToC for journal record

Background:
  Given I'm logged in as a DTU employee

Scenario: User wants to see Table of Contents for journal
  When I have searched for "Polski format:journal"
   And I click on the first document
  Then I should see a journal with table of contents
   And I should see at least 2 years of issues
   And I should see the first issue as selected
   And I should see the list of articles in the issue

Scenario: User wants to see the full table of contents
  When I have searched for "Polski format:journal"
   And I click on the first document
   And I click "Show full table of contents"
  Then I should not see the "Show full table of contents" link
   And I should see at least 5 years of issues

Scenario: Display toc for journal without issues
  When I have searched for "German medical science format:journal"
   And I click on the first document
  Then I should see a journal with table of contents

Scenario: Navigating between issues
  When I have searched for "Polski format:journal"
   And I click on the first document
  Then I should not see the "Next issue" link
  When I click "Previous issue"
  Then I should see a journal with table of contents
   And I should see the second issue as selected
  When I click "Next issue"
  Then I should see a journal with table of contents
   And I should see the first issue as selected

Scenario: Open ToC from article
  When I have searched for "Sprawozdanie"
   And I click on the first document
   And I click "Open table of contents"
  Then I should see a journal with table of contents

Scenario: Open ToC from article and do search from ToC
  When I have searched for "Sprawozdanie"
   And I click "Grabowski, Marcin"
  Then I should see a limit constraint for "Author"
  When I click on the first document
   And I click "Open table of contents"
  Then I should see a journal with table of contents
   And I should not see a limit constraint for "Author"
  When I search for "Integer"
   And I click "Greaves, Gary"
  Then I should see a limit constraint for "Author"

Scenario: Finding all articles in issue from ToC
  When I have searched for "Polski format:journal"
   And I click on the first document
   And I click "Find all articles in same issue"
  Then I should see the result page
   And I should see a limit constraint for "Articles in"
   And I should see a limit constraint that begins with "Polski"

Scenario: Finding all articles in issue from article
  When I have searched for "Journal of Software Engineering and Applications"
   And I click "Find all articles in same issue"
  Then I should see the result page
   And I should see a limit constraint for "Articles in"
   And I should see a limit constraint that begins with "Journal of Software Engineering and Applications"