Feature: DTU users submits forms

In order to request library assistance on finding a
journal article, a conference article or a book
as a DTU user
I should be able to fill in and submit the forms.

Background: Logged in as a DTU user
  Given I'm logged in as a DTU user

Scenario: Submitting a fully filled form for journal article
  Given I'm on the "can't find" form for "journal article"
   When I fill in the "article" section with the following values
     | Article title | Non-existing article  |
     | Author        | Doe, John             |
     | DOI           | 10.1000/non-existing  |
    And I fill in the "journal" section with the following values
     | Journal title | Non-existing journal  |
     | ISSN          | 12345678              |
     | Vol.          | 1                     |
     | Iss.          | 12                    |
     | Year          | 2012                  |
     | Pages         | 12-14                 |
    And I fill in the "notes" section with the following values
     | Notes         | Urgent! Please hurry! |
    And I click "Send request"
   Then I should see "Your request has been sent with the following values:"
    And I should see the "article" section with the following values
     | Article title | Non-existing article  |
     | Author        | Doe, John             |
     | DOI           | 10.1000/non-existing  |
    And I should see the "journal" section with the following values
     | Journal title | Non-existing journal  |
     | ISSN          | 12345678              |
     | Vol.          | 1                     |
     | Iss.          | 12                    |
     | Year          | 2012                  |
     | Pages         | 12-14                 |
    And I should see the "notes" section with the following values
     | Notes         | Urgent! Please hurry! |

Scenario: Submitting a fully filled form for conference article
  Given I'm on the "can't find" form for "conference article"
   When I fill in the "article" section with the following values
     | Article title | Non-existing article  |
     | Author        | Doe, John             |
     | DOI           | 10.1000/non-existing  |
    And I fill in the "proceedings" section with the following values
     | Proceedings/series title | Proceedings on an exciting conference |
     | ISSN/ISBN                | 12345678                              |
     | Pages                    | 12-23                                 |
    And I fill in the "conference" section with the following values
     | Conference title         | An exciting conference                |
     | No.                      | 23                                    |
     | Year                     | 1999                                  |
     | Location                 | London                                |
    And I fill in the "notes" section with the following values
     | Notes         | Urgent! Please hurry! |
    And I click "Send request"
   Then I should see "Your request has been sent with the following values:"
    And I should see the "article" section with the following values
     | Article title | Non-existing article  |
     | Author        | Doe, John             |
     | DOI           | 10.1000/non-existing  |
    And I should see the "proceedings" section with the following values
     | Proceedings/series title | Proceedings on an exciting conference |
     | ISSN/ISBN                | 12345678                              |
     | Pages                    | 12-23                                 |
    And I should see the "conference" section with the following values
     | Conference title         | An exciting conference                |
     | No.                      | 23                                    |
     | Year                     | 1999                                  |
     | Location                 | London                                |
    And I should see the "notes" section with the following values
     | Notes         | Urgent! Please hurry! |


Scenario: Submitting form for book
