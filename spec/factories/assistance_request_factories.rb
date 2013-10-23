FactoryGirl.define do
  factory :journal_article_assistance_request do
    article_title  'Testing applications using RSpec'
    journal_title  'Journal of Testing Methods'
    journal_volume '12'
    journal_issue  '4'
    journal_year   '2010'
    journal_pages  '12-15'
  end

  factory :journal_article_assistance_request_form_post, :class => Hash do
    assistance_request { attributes_for :journal_article_assistance_request }
    genre :journal_article

    initialize_with { attributes }
  end

  factory :conference_article_assistance_request do
    article_title     'How to increase your testability'
    proceedings_pages '12'
    conference_title  'Annual Conference on Testing Methods'
    conference_year   '2009'
  end

  factory :conference_article_assistance_request_form_post, :class => Hash do
    assistance_request { attributes_for :conference_article_assistance_request }
    genre :conference_article

    initialize_with { attributes }
  end

  factory :book_assistance_request do
    book_title 'Testing Super-bible'
    book_year  '1999'
  end

  factory :book_assistance_request_form_post, :class => Hash do
    assistance_request { attributes_for :book_assistance_request }
    genre :book

    initialize_with { attributes }
  end
end
