Feature: Boost Local (DTU) Content

  Scenario: Search results from orbit are marked as homegrown
    Given I'm logged in
    When I search for "Resistance"
    Then I should see "Resistance in bacteria of the food chain: epidemiology and control strategies" with local boost
    Then I should see "Powdery Mildew Resistance Genes in Wheat: Identification and Genetic Analysis" without local boost

  Scenario: Show page for content from orbit has local boost
    Given I'm logged in
    When I go to the record page for "Resistance in bacteria of the food chain: epidemiology and control strategies"
    Then the document should have local boost

  Scenario: Show page for content NOT from orbit does not have local boost
    Given I'm logged in
    When I go to the record page for "Powdery Mildew Resistance Genes in Wheat: Identification and Genetic Analysis"
    Then the document should not have local boost