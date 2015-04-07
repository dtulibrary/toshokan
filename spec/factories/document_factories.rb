FactoryGirl.define do

  factory :solr_document do
    skip_create

    initialize_with { SolrDocument.new(attributes) }

    factory :journal_article, :class => Hash do
      title_ts    ['Journal title']
      format      'article'
      subformat_s 'journal_article'
    end

    factory :conference_article do
      title_ts    ['Conference article title']
      format      'article'
      subformat_s 'conference_paper'
    end

    factory :book do
      title_ts    ['Book title']
      format      'book'
      subformat_s 'book'
    end

    factory :thesis do
      title_ts    ['Thesis title']
      format      'thesis'

      factory :phd_thesis do
        subformat_s 'phd'
      end

      factory :doctoral_thesis do
        subformat_s 'doctoral'
      end
    end

    factory :report do
      title_ts    ['Report title']
      format      'article'
      subformat_s 'report'
    end

    factory :standard do
      title_ts    ['Standard title']
      format      'article'
      subformat_s 'standard'
    end

    factory :patent do
      title_ts    ['Patent title']
      format      'other'
      subformat_s 'patent'
    end

    factory :other do
      title_ts    ['Other title']
      format      'other'
      subformat_s 'unknown'
    end
  end

end
