# Class representing a scan order
# It has 3 kinds of ids: a regular DB id, an id based on the DB id (for use with DIBS and customers)
# and a UUID used for URLs 
class Order < ActiveRecord::Base
  belongs_to :user
  has_many :order_events

  validates :open_url, :supplier, :price, :vat, :currency, :email, :presence => true

  attr_accessible :user, :uuid, :open_url, :supplier, :price, :vat, :currency, :email
  attr_accessor :flow

  # Convert the OpenURL of ordered document to a hash with similarly named keys like those used in solr documents
  # TODO: Return a SolrDocument instead from SolrDocument.import_from_openurl_kev or something like that
  def document
    unless @document
      @document = { :open_url => open_url }
      ['author_ts', 'title_ts', 'journal_title_ts', 'issn_ss', 'pub_date_tis', 'journal_vol_ssf', 'journal_issue_ssf', 'journal_page_ssf', 'doi_ss'].each do |field|
        @document[field] = []
      end 

      field_map = { 
        'rft.au' => 'author_ts',
        'rft.atitle' => 'title_ts',
        'rft.jtitle' => 'journal_title_ts',
        'rft.issn' => 'issn_ss',
        'rft.year' => 'pub_date_tis',
        'rft.volume' => 'journal_vol_ssf',
        'rft.issue' => 'journal_issue_ssf',
        'rft.pages' => 'journal_page_ssf',
        'rft.doi' => 'doi_ss'
      }   

      open_url.scan /([^&=]+)=([^&]*)/ do |k,v|
        @document[field_map[k]].try :<<, URI.unescape(v.gsub '+', '%20')
      end 
    end

    return @document
  end

  # Since all servers will use the same DIBS and DIBS requires unique order ids,
  # we prefix the order ids with a unique prefix per server - also we zero-pad
  # the order id (to 8 digits) so it looks more order id-ish.
  def dibs_order_id
    persisted? ? "%s%08d" % [Orders.order_id_prefix, self.id] : nil
  end

  # A "fake" finder that will parse the database id from the DIBS order id and
  # use the finder that is based on database ids.
  def self.find_by_dibs_order_id dibs_order_id
    id = $1 if dibs_order_id =~ /^[^0-9]*0*(.+)/
    self.find id
  end

  # Intercept and ensure document is recreated
  def open_url= open_url
    self[:open_url] = open_url
    @document = nil
  end

  # Intercept and convert to symbol
  def payment_status
    self[:payment_status].try :to_sym
  end

  # Intercept and convert to symbol
  def delivery_status
    self[:delivery_status].try :to_sym
  end

  # Intercept and convert to symbol
  def supplier
    self[:supplier].try :to_sym
  end

  # Intercept and convert to symbol
  def currency
    self[:currency].try :to_sym
  end

end