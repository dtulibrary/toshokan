Feature: Submit forms

DTU employees and students can submit the request assistance forms,
sending them to the confirmation page.

If required fields are missing, submission is cancelled and the
form is displayed with the submitted values and error indicators on the
fields that are missing values.

Scenario Outline: DTU user submits a valid request assistance form
  Given I'm logged in as a DTU <user_type>
    And I'm on the "request assistance" form for "<genre>"
   When I submit the form with valid data
    And I decline any resolver results
   Then I should see the confirmation page

Examples:
  | user_type | genre              |
  | employee  | journal article    |   
  | employee  | conference article |
  | employee  | book               |
  | employee  | thesis             |
  | employee  | report             |
  | employee  | standard           |
  | employee  | patent             |
  | employee  | other              |
  | student   | journal article    |   
  | student   | conference article |
  | student   | book               |
  | student   | thesis             |
  | student   | report             |
  | student   | standard           |
  | student   | patent             |
  | student   | other              |

Scenario Outline: DTU user submits an invalid request assistance form for journal article
  Given I'm logged in as a DTU <user_type>
    And I'm on the "request assistance" form for "journal article"
   When I submit the form
   Then I should see the "request assistance" form for "journal article"
    And I should see "One or more required fields are empty"
    And I should see an error in the "Title" field in the "article" form section
    And I should see errors in the "Title", "Volume", "Year" and "Pages" fields in the "journal" form section

Examples:
  | user_type |
  | employee  |
  | student   |   

Scenario Outline: DTU user submits invalid request assistance form for conference article
  Given I've logged in as a DTU <user_type>
    And I'm on the "request assistance" form for "conference article"
   When I submit the form
   Then I should see the "request assistance" form for "conference article"
    And I should see "One or more required fields are empty"
    And I should see an error in the "Title" field in the "article" form section
    And I should see errors in the "Title", "Pages" and "Year" fields in the "conference" form section

Examples:
  | user_type |
  | employee  |
  | student   |

Scenario Outline: DTU user submits invalid request assistance form for book
  Given I've logged in as a DTU <user_type>
    And I'm on the "request assistance" form for "book"
   When I submit the form
   Then I should see the "request assistance" form for "book"
    And I should see "One or more required fields are empty"
    And I should see errors in the "Title" and "Year" fields in the "book" form section

Examples:
  | user_type |
  | employee  |
  | student   |

Scenario Outline: DTU user submits invalid request assistance form for thesis
  Given I've logged in as a DTU <user_type>
    And I'm on the "request assistance" form for "thesis"
   When I submit the form
   Then I should see the "request assistance" form for "thesis"
    And I should see "One or more required fields are empty"
    And I should see errors in the "Title", "Author" and "Year" fields in the "thesis" form section

Examples:
  | user_type |
  | employee  |
  | student   |

Scenario Outline: DTU user submits invalid request assistance form for report
  Given I've logged in as a DTU <user_type>
    And I'm on the "request assistance" form for "report"
   When I submit the form
   Then I should see the "request assistance" form for "report"
    And I should see "One or more required fields are empty"
    And I should see an error in the "Title" field in the "report" form section
    And I should see an error in the "Year" field in the "host" form section

Examples:
  | user_type |
  | employee  |
  | student   |

Scenario Outline: DTU user submits invalid request assistance form for standard
  Given I've logged in as a DTU <user_type>
    And I'm on the "request assistance" form for "standard"
   When I submit the form
   Then I should see the "request assistance" form for "standard"
    And I should see "One or more required fields are empty"
    And I should see errors in the "Title" and "Year" fields in the "standard" form section

Examples:
  | user_type |
  | employee  |
  | student   |

Scenario Outline: DTU user submits invalid request assistance form for patent
  Given I've logged in as a DTU <user_type>
    And I'm on the "request assistance" form for "patent"
   When I submit the form
   Then I should see the "request assistance" form for "patent"
    And I should see "One or more required fields are empty"
    And I should see errors in the "Title" and "Year" fields in the "patent" form section

Examples:
  | user_type |
  | employee  |
  | student   |

Scenario Outline: DTU user submits invalid request assistance form for other
  Given I've logged in as a DTU <user_type>
    And I'm on the "request assistance" form for "other"
   When I submit the form
   Then I should see the "request assistance" form for "other"
    And I should see "One or more required fields are empty"
    And I should see an error in the "Title" field in the "other" form section
    And I should see an error in the "Year" field in the "host" form section

Examples:
  | user_type |
  | employee  |
  | student   |
