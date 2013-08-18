class User < ActiveRecord::Base

  include Blacklight::User

  attr_accessible :email, :identifier, :provider, :user_data
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
      find_by_provider_and_identifier(provider, user_data['id']) ||
      self.create(:provider => provider, :identifier => user_data['id'])
    user.user_data = user_data
    user.email = user_data['email']
    user.save
    user
  end

  def public?
    !dtu?
  end

  def dtu?
    authenticated? && user_data && user_data['dtu']
  end

  def employee?
    dtu? && user_data['dtu']['user_type'] == 'dtu_empl'
  end

  def student?
    dtu? && user_data['dtu']['user_type'] == 'student'
  end

  def guest?
    dtu? && user_data['dtu']['user_type'] == 'guest'
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

  def to_s
    if authenticated?
      if dtu?
        "%s %s" % [user_data['dtu']['firstname'], user_data['dtu']['lastname']]
      else
        email
      end
    else
      'Anonymous'
    end
  end
end
