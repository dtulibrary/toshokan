class User < ActiveRecord::Base

  include Blacklight::User

  #attr_accessible :email, :identifier, :provider, :user_data
  serialize :user_data, JSON

  attr_accessor :impersonating, :walk_in, :internal, :campus, :orders_enabled
  alias :impersonating? :impersonating
  alias :walk_in? :walk_in
  alias :internal? :internal
  alias :campus? :campus
  alias :orders_enabled? :orders_enabled

  has_and_belongs_to_many :roles

  has_many :subscriptions, :dependent => :destroy
  has_many :tags, :dependent => :destroy
  has_many :taggings, :through => :tags

  def self.create_or_update_with_user_data(provider, user_data)
    user =
      find_by_provider_and_identifier(provider, user_data['id'].to_s) ||
      self.create(:provider => provider, :identifier => user_data['id'].to_s)
    user.user_data = user_data
    user.email = user_data['email']
    user.save
    user
  end

  def self.search(query)
    if query
      logger.debug "Query: #{query}"

      tokens = query.split
      logger.debug "Tokens: #{tokens}"

      query = where('1=1')
      tokens.each do |token|
        query = query.where('LOWER(user_data) LIKE ?', "%#{token.downcase}%")
      end
      logger.debug { "Found users with identifiers: #{query.map(&:identifier)}" }
      query.order(:identifier)
    else
      where('1=0')
    end
  end

  def roles
    impersonating ? [] : super
  end

  def public?
    !dtu?
  end

  def dtu?
    authenticated? && user_data && user_data['dtu']
  end

  def employee?
    if impersonating.is_a? String
      impersonating == 'employee'
    else
      dtu? && user_data['dtu']['user_type'] == 'dtu_empl'
    end
  end

  def student?
    if impersonating.is_a? String
      impersonating == 'student'
    else
      dtu? && user_data['dtu']['user_type'] == 'student'
    end
  end

  def authenticated?
    # Only authenticated users are stored in the database
    id
  end

  def type
    if student?
      return :dtu_student
    elsif employee?
      return :dtu_staff
    elsif walk_in?
      return :walkin
    elsif authenticated?
      return :public
    else
      return :anonymous
    end
  end

  def image_url
    dtu? && user_data['dtu']['image_url']
  end

  def tag(document, tag_name)
    bookmark = bookmarks.find_or_create_by_document_id(document.id)
    tag = tags.find_or_create_by_name(tag_name)
    bookmark.tags << tag unless bookmark.tags.exists?(tag)
    bookmark.save
    tag
  end

  def tags_for(bookmark_document_or_document_id)
    document_id = case
                  when bookmark_document_or_document_id.is_a?(String)
                    bookmark_document_or_document_id
                  when bookmark_document_or_document_id.respond_to?(:document_id)
                    bookmark_document_or_document_id.document_id
                  else
                    bookmark_document_or_document_id.id
                  end
    bookmark = bookmarks.includes(:tags).find_by_document_id(document_id)
    bookmark && bookmark.tags.order(:name)
  end

  def bookmark(document_or_document_id)
    document_id = case
                  when document_or_document_id.is_a?(String)
                    document_or_document_id
                  else
                    document_or_document_id.id
                  end
    bookmarks.find_or_create_by_document_id(document_id)
  end

  def name
    if impersonating == 'anonymous'
      'Anonymous'
    elsif impersonating == 'student'
      'a Student'
    elsif impersonating == 'employee'
      'an Employee'
    elsif authenticated?
      if dtu?
        "%s %s" % [user_data['dtu']['firstname'], user_data['dtu']['lastname']]
      else
        email
      end
    else
      'Anonymous'
    end
  end

  def email
    user_data && user_data['email']
  end

  def cwis
    dtu? && user_data['dtu']['matrikel_id']
  end

  def to_s
    name
  end

  def address
    user_data && user_data['address']
  end
end
