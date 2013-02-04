  class User < ActiveRecord::Base
  include Blacklight::User

  attr_accessible :email, :firstname, :identifier, :lastname, :provider, :username, :image_url
  attr_accessor :impersonating, :walk_in
  alias :impersonating? :impersonating
  alias :walk_in? :walk_in

  has_many :profiles
  has_and_belongs_to_many :roles

  has_many :subscriptions, :dependent => :destroy
  has_many :tags, :dependent => :destroy
  has_many :taggings, :through => :tags


  def self.create_or_update_with_account(provider, account)
    user =
      find_by_provider_and_identifier(provider, account.cwis) ||
      self.create(:provider => provider, :identifier => account.cwis)
    user.username = account.username
    user.firstname = account.firstname
    user.lastname = account.lastname
    user.email = account.email
    user.image_url = account.image_url

    user.profiles.clear
    account.profiles.each do |dtubase_profile|
      user.profiles.build(:active => dtubase_profile.active,
                          :kind => dtubase_profile.kind,
                          :email => dtubase_profile.email,
                          :identifier => dtubase_profile.id,
                          :org_id => dtubase_profile.org_id)



    end
    user.save
    user
  end

  def active_profiles
    profiles.find_all { |p| p.active }
  end

  def active?
    profiles.any? { |p| p.active }
  end

  def employee_profiles
    profiles.find_all { |p| p.kind == 'employee'}
  end

  def student_profiles
    profiles.find_all { |p| p.kind == 'student'}
  end

  def guest_profiles
    profiles.find_all { |p| p.kind == 'guest'}
  end

  def active_employee_profiles
    employee_profiles.find_all { |p| p.active }
  end

  def active_student_profiles
    student_profiles.find_all { |p| p.active }
  end

  def active_guest_profiles
    guest_profiles.find_all { |p| p.active }
  end

  def employee?
    employee_profiles.any? { |p| p.active }
  end

  def student?
    student_profiles.any? { |p| p.active }
  end

  def guest?
    guest_profiles.any? { |p| p.active }
  end

  def authenticated?
    # Only authenticated users are stored in the database
    id
  end

  def tag(document, tag_name)
    bookmark = bookmarks.find_or_create_by_document_id(document.id)
    tag = tags.find_or_create_by_name(tag_name)
    bookmark.tags << tag unless bookmark.tags.exists?(tag)
    bookmark.save
    tag
  end

  def tags_for(bookmark_document_or_document_id)
    if bookmark_document_or_document_id.is_a?(String)
      document_id = bookmark_document_or_document_id
    elsif bookmark_document_or_document_id.respond_to?(:document_id)
      document_id = bookmark_document_or_document_id.document_id
    else
      document_id = bookmark_document_or_document_id.id
    end

    bookmarks.includes(:tags).find_by_document_id(document_id).tags.order(:name)
  end

  def to_s
    "%s %s" % [firstname, lastname]
  end

  def type
    if student?
      return "dtu_student"
    elsif employee?
      return "dtu_staff"
    elsif walk_in?
      return "walkin"
    elsif authenticated?
      return "public"
    else
      return "anonymous"
    end
  end

end
