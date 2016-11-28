class Query < ActiveRecord::Base
  has_one :query_result

  validates :name, :query_string, presence: true
  validates :name, uniqueness: true

  FORMATS           = ['article', 'book', 'other']
  PUBLICATION_YEARS = [-1, 0, 1]
  ACCESS            = ['dtu']

  # Params:
  #   options[:formats]           : which formats to search for
  #   options[:publication_years] : which publication years (offsets from current year) to search for
  #   options[:access]            : which access modifiers to search for
  def self.common_filter_query(options = {})
    options = {
      :formats           => FORMATS,
      :publication_years => PUBLICATION_YEARS,
      :access            => ACCESS
    }.merge(options)

    current_year = Time.new.year

    [
      "format:(#{options[:formats].join(' OR ')})",
      "pub_date_tis:(#{options[:publication_years].map {|y| current_year + y}.join(' OR ')})",
      "access_ss:(#{options[:access].join(' OR ')})"
    ]
  end

  def self.normalize(query_string)
    query_string.split.join(' ')
  end

  # Combine this query and the common filter query
  def to_solr_query
    [::Query.normalize(query_string), ::Query.common_filter_query].flatten.join(' AND ')
  end
end
