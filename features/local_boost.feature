Feature: Boost Local (DTU) Content

  Scenario: Search results from orbit are marked as homegrown
    Given I'm logged in
    When I search for "Resistance"
    Then I should see "Resistance in bacteria of the food chain: epidemiology and control strategies" with local boost
    Then I should see "Powdery Mildew Resistance Genes in Wheat: Identification and Genetic Analysis" without local boost