class Query < ActiveRecord::Base
  has_one :query_result

  validates :name, :query_string, presence: true
  validates :name, uniqueness: true

  FORMATS           = ['article', 'book', 'other']
  PUBLICATION_YEARS = [-1, 0, 1]

  def self.common_filter_query
    current_year = Time.new.year
    [
      "format:(#{FORMATS.join(' OR ')})",
      "pub_date_tis:(#{PUBLICATION_YEARS.map {|y| current_year + y}.join(' OR ')})",
      "access_ss:dtu"
    ]
  end

  def self.normalize(query_string)
    query_string.gsub(/^\s+|\s+$/, '')
                .gsub(/\s+/, ' ')
  end

  def to_solr_query
    [::Query.normalize(query_string), ::Query.common_filter_query].flatten.join(' AND ')
  end
end
