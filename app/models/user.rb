class User < ActiveRecord::Base
  include Blacklight::User

  attr_accessible :email, :firstname, :identifier, :lastname, :provider, :username
  attr_accessor :impersonating
  alias :impersonating? :impersonating
  validates :provider, presence: true 

  has_many :profiles
  has_and_belongs_to_many :roles

  acts_as_tagger
  
  def self.create_or_update_with_account(provider, account)
    user =
      find_by_provider_and_identifier(provider, account.cwis) ||
      self.create(:provider => provider, :identifier => account.cwis)
    user.username = account.username
    user.firstname = account.firstname
    user.lastname = account.lastname
    user.email = account.email
    
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

  def to_s
    "%s %s" % [firstname, lastname]
  end

end
