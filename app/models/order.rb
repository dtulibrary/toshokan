# Class representing a scan order
# It has 3 kinds of ids: a regular DB id, an id based on the DB id (for use with DIBS and customers)
# and a UUID used for URLs 
class Order < ActiveRecord::Base
  belongs_to :user
  has_many :order_events

  validates :open_url, :supplier, :price, :vat, :currency, :email, :presence => true

  before_save :set_derived_fields

  attr_accessible :user, :uuid, :open_url, :supplier, :price, :vat, :currency, :email
  attr_accessor :flow

  def set_derived_fields
    self.user_type ||= user_id.blank? ? 'anonymous' : user.type
    self.origin    ||= assistance_request_id.blank? ? 'scan_request' : 'assistance_request'
    unless created_at.blank?
      self.created_year  ||= created_at.year
      self.created_month ||= created_at.month
    end
    unless delivered_at.blank?
      self.delivered_year  ||= delivered_at.year
      self.delivered_month ||= delivered_at.month
      self.duration_hours = ((delivered_at - created_at) / (60*60)).to_i
    end
  end

  # Convert the OpenURL of ordered document to a hash with similarly named keys like those used in solr documents
  # TODO: Return a SolrDocument instead from SolrDocument.import_from_openurl_kev or something like that
  def document
    unless @document
      @document = { :open_url => open_url }

      field_map = { 
        'rft.au'     => 'author_ts',
        'rft.atitle' => 'title_ts',
        'rft.jtitle' => 'journal_title_ts',
        'rft.btitle' => 'title_ts',
        'rft.issn'   => 'issn_ss',
        'rft.year'   => 'pub_date_tis',
        'rft.date'   => 'pub_date_tis',
        'rft.volume' => 'journal_vol_ssf',
        'rft.issue'  => 'journal_issue_ssf',
        'rft.pages'  => 'journal_page_ssf',
        'rft.spage'  => 'journal_page_ssf',
        'rft.epage'  => 'journal_page_ssf',
        'rft.doi'    => 'doi_ss',
        'rft.pub'    => 'publisher_ts',
        'rft.place'  => 'publication_place_ts',
      }   

      field_map.values.uniq.each do |field|
        @document[field] = []
      end

      open_url.scan /([^&=]+)=([^&]*)/ do |k,v|
        @document[field_map[k]].try :<<, URI.decode_www_form_component(v)
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

  # Indicate whether this order may have DRM restrictions
  def drm?
    !(user && user.dtu?)
  end

  def cancelled?
    delivery_status == :cancelled
  end

  def cancel_reason
    order_events.where(:name => 'delivery_cancelled').last.try :data
  end

  def library_support_issue
    order_events.where(:name => 'delivery_manual').last.try :data
  end

  def assistance_request
    AssistanceRequest.find_by_id assistance_request_id
  end
end
