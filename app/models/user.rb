  class User < ActiveRecord::Base
  include Blacklight::User

  attr_accessible :email, :firstname, :identifier, :lastname, :provider, :username, :image_url
  attr_accessor :impersonating
  alias :impersonating? :impersonating

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
    logger.debug "image url is #{account.image_url}"

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

  def anonymous?
    # Anonymous users are not stored in the database so they don't have an ID
    !id
  end

  def tag(document, tag_name)
    tag = tags.find_or_create_by_name(tag_name)
    taggings.build(:solr_id => document.id, :tag => tag).save
    tag
  end

  def subscribe(tag)
    subscriptions.find_or_create_by_tag_id(tag.id)
  end

  def tags_for(documents)
    if (documents.respond_to?(:map))
      ids = documents.map(&:id)
      r = Hash.new([])
      tags.includes(:taggings).where('taggings.solr_id' => ids)
	.each{|tag| tag.taggings.each{|tagging| r[tagging.solr_id] += [tag]}}
      r
    else
      ids = documents.id
      tags.includes(:taggings).where('taggings.solr_id' => ids)
    end
  end

  def subscribed_tags_for(documents)
    if (documents.respond_to?(:map))
      ids = documents.map(&:id)
      r = Hash.new([])
      subscriptions.includes(:tag => [:taggings]).where('tags.shared' => true).where('taggings.solr_id' => ids)
	.each{|subscription| subscription.tag.taggings.each{|tagging| r[tagging.solr_id] += [subscription.tag]}}
      r
    else
      ids = documents.id
      subscriptions.includes(:tag => [:taggings]).where('tags.shared' => true).where('taggings.solr_id' => ids).collect{|s| s.tag}
    end
  end

  def shared_tags
    tags.where(:shared => true)
  end

  def subscribed_tags
    subscriptions.includes(:tag).where('tags.shared' => true).collect{|s| s.tag}
  end

  def subscribed_taggings
    subscriptions.includes(:tag => [:taggings]).where('tags.shared' => true).collect{|s| s.tag.taggings}.flatten
  end

  def to_s
    "%s %s" % [firstname, lastname]
  end

end
