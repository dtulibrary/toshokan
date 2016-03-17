Feature: Boost Local (DTU) Content

  Scenario: Search results from orbit are marked as homegrown
    Given I'm logged in
    When I search for "source_ss:orbit"
    Then all the documents should have local boost

  Scenario: Search results from non-orbit sources are not marked as homegrown
    Given I'm logged in
    When I search for "source_ss:rdb_ku"
    Then none of the documents should have local boost

  Scenario: Show page for content from orbit has local boost
    Given I'm logged in
    When I search for "source_ss:orbit"
     And I click on the first document
    Then the document should have local boost

  Scenario: Show page for content NOT from orbit does not have local boost
    Given I'm logged in
    When I search for "source_ss:rdb_ku"
     And I click on the first document
    Then the document should not have local boost
