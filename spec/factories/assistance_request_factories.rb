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

  factory :journal_article_from_index_assistance_request, class: JournalArticleAssistanceRequest do
    article_title  'Using an Ontology to Help Reason about the Information Content of Data'
    journal_title  'Journal of Software Engineering and Applications'
    journal_volume '03'
    journal_issue  '07'
    journal_year   '2010'
    journal_pages  '629-643'
  end

  factory :journal_article_from_index_assistance_request_form_post, :class => Hash do
    assistance_request { attributes_for :journal_article_from_index_assistance_request }
    genre :journal_article

    initialize_with { attributes }
  end

  factory :conference_article_assistance_request do
    article_title     'How to increase your testability'
    conference_title  'Annual Conference on Testing Methods'
    conference_year   '2009'
    conference_pages  '12'
  end

  factory :conference_article_assistance_request_form_post, :class => Hash do
    assistance_request { attributes_for :conference_article_assistance_request }
    genre :conference_article

    initialize_with { attributes }
  end

  factory :book_assistance_request do
    book_title 'Testing Super-bible'
    book_year  '1999'

    factory :book_suggestion_assistance_request do
      book_suggest '1'
      notes        'This book is so good'
    end
  end

  factory :book_assistance_request_form_post, :class => Hash do
    assistance_request { attributes_for :book_assistance_request }
    genre :book

    initialize_with { attributes }
  end

  factory :book_suggestion_assistance_request_form_post, :class => Hash do
    assistance_request { attributes_for :book_suggestion_assistance_request }
    genre :book

    initialize_with { attributes }
  end

  factory :thesis_assistance_request do
    thesis_title  'Thesis Title'
    thesis_author 'Thesis Author'
    thesis_year   '1999'
  end

  factory :thesis_assistance_request_form_post, :class => Hash do
    assistance_request { attributes_for :thesis_assistance_request }
    genre :thesis

    initialize_with { attributes }
  end

  factory :report_assistance_request do
    report_title 'Report Title'
    host_year  '1999'
  end

  factory :report_assistance_request_form_post, :class => Hash do
    assistance_request { attributes_for :report_assistance_request }
    genre :report

    initialize_with { attributes }
  end

  factory :standard_assistance_request do
    standard_title 'Standard Title'
    standard_year  '1999'
  end

  factory :standard_assistance_request_form_post, :class => Hash do
    assistance_request { attributes_for :standard_assistance_request }
    genre :standard

    initialize_with { attributes }
  end

  factory :patent_assistance_request do
    patent_title 'Patent Title'
    patent_year '1999'
  end

  factory :patent_assistance_request_form_post, :class => Hash do
    assistance_request { attributes_for :patent_assistance_request }
    genre :patent

    initialize_with { attributes }
  end
  
  factory :other_assistance_request do
    other_title 'Other Title'
    host_year  '1999'
  end

  factory :other_assistance_request_form_post, :class => Hash do
    assistance_request { attributes_for :other_assistance_request }
    genre :other

    initialize_with { attributes }
  end

end
