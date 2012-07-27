class Dtubase::Account
  include HappyMapper
  tag 'account'
  attribute :id, String, :tag => 'matrikel_id'
  attribute :cwis, String, :tag => 'matrikel_id'
  attribute :username, String, :tag => 'username'
  attribute :email, String, :tag => 'official_email_address'
  attribute :firstname, String, :tag => 'firstname'
  attribute :lastname, String, :tag => 'lastname'
  attribute :primary_profile_id, String
  attribute :active, Boolean, :tag => 'has_active_profile'
  has_many :employee_profiles, EmployeeProfile, :tag => 'profile_employee'
  has_many :student_profiles, StudentProfile, :tag => 'profile_student'
  has_many :guest_profiles, GuestProfile, :tag => 'profile_guest'

  def profiles
    [employee_profiles, student_profiles, guest_profiles].flatten.compact
  end

  def self.find(attrs)
    config = Dtubase.config
    identifier = attrs[:cwis] || attrs[:username]
    if (config.test_mode)
      xml = Dtubase.mock_account_for(identifier)
    else
      attr = 
      if attrs[:cwis]
        "matrikel_id"
      else
        "username"
      end
      url = "#{config.url}?" +
      URI.encode_www_form(
        :XPathExpression => "/account[@#{attr}=\'%s\']" % identifier,
        :username => config.username,
        :password => config.password,
        :dbversion => 'dtubasen'
      )
      response = HTTParty.get(url)
      raise "Could not get user with #{attrs.keys.first} containing #{identifier} from "\
            "DTUbasen with request #{url}. Message: #{response.message}." unless response.success?
      xml = response.body
    end
    account = self.parse(xml, :single => true)
    account != [] ? account : nil
  end

  def self.find_by_cwis(cwis)
    find(cwis: cwis)
  end

  def self.find_by_username(username)
    find(username: username)
  end
end
