class User < ActiveRecord::Base
  include Blacklight::User

  serialize :user_data, JSON

  attr_accessor :impersonating, :walk_in, :internal, :campus, :orders_enabled
  alias_method :impersonating?, :impersonating
  alias_method :walk_in?, :walk_in
  alias_method :internal?, :internal
  alias_method :campus?, :campus
  alias_method :orders_enabled?, :orders_enabled

  has_and_belongs_to_many :roles

  has_many :subscriptions, :dependent => :destroy
  has_many :tags, :dependent => :destroy
  has_many :taggings, :through => :tags

  def self.create_or_update_with_user_data(provider, user_data)
    user =
      find_by_provider_and_identifier(provider, user_data['id'].to_s) ||
      create(:provider => provider, :identifier => user_data['id'].to_s)
    user.user_data = user_data
    user.email = user_data['email']
    user.save
    user
  end

  def self.search(query)
    if query
      tokens = query.split
      query = where('1=1')
      tokens.each do |token|
        query = query.where('LOWER(user_data) LIKE ?', "%#{token.downcase}%")
      end
      query.order(:identifier)
    else
      where('1=0')
    end
  end

  def roles
    impersonating ? [] : super
  end

  def super_admin?
    @super_admin = (employee? && roles.collect(&:code).include?('ADM'))
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
    return :dtu_student if student?
    return :dtu_staff if employee?
    return :walkin if walk_in?
    return :public if authenticated?
    :anonymous
  end

  def access_type
    case self.type
      when :dtu_student, :dtu_staff, :walkin
        'dtu'
      when :anonymous, :public
        'dtupub'
      else
        ''
      end
  end

  def image_url
    dtu? && user_data['dtu']['image_url']
  end

  def bookmark(document)
    existing_bookmark_for(document) || bookmarks.create(document: document)
  end

  def tag(document, tag_name)
    bookmark = existing_bookmark_for(document) || bookmarks.create(document: document)
    tag = tags.find_or_create_by(name: tag_name)
    bookmark.tags << tag unless bookmark.tags.exists?(tag)
    bookmark.save
    tag
  end

  def existing_tags_for(document)
    bookmark = existing_bookmark_for(document)
    bookmark && bookmark.tags.order(:name)
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
        "#{user_data['dtu']['firstname']} #{user_data['dtu']['lastname']}"
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
