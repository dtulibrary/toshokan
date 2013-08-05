# encoding: utf-8

Then /^the user should be "(.*?)"$/ do |username|
  page.should have_selector '#util-links a', :text => username
end

Given /^the following users? exists?:$/ do |table|
  table.map_column!('roles') { |roles| roles.scan(/"(.*?)"/).flatten }
  table.hashes.each do |hash|
    hash['name'] ||= 'John Doe'
    *given_names, birth_name = hash['name'].split ' '
    user = User.new(
      :identifier => hash['cwis'],
      :username => hash['username'] || 'john_doe',
      :provider => hash['provider'] || 'dtu_cas',
      :firstname => given_names.join(' '),
      :lastname => birth_name,
      :email => hash['email'] || 'john_doe@example.com'
    )
    hash['roles'].each { |role| user.roles << Role.find_by_name(role) } 
    user.save!
    account = Dtubase::Account.new
    account.cwis = user.identifier
    account.firstname = user.firstname
    account.lastname = user.lastname
    Dtubase::Account.stub(:find_by_cwis).with(user.identifier).and_return(account)
  end
end

Given /^I(?: am|'m) logged in as user with (.*?) "(.*?)"$/ do |key, value|
  user = nil
  case key
  when 'cwis'
    user = User.find_by_identifier value
  when 'username'
    user = User.find_by_username value
  end
  log_in user
end

Given /^I'm logged in as user with the role "(.*?)"$/ do |arg1|
  role = Role.find_by_name(arg1)
  raise "Role doesn't exist for name #{arg1}" unless role
  user = User.new(identifier: arg1+'_test_id', username: arg1+'_test_username', provider: 'dtu_cas') 
  user.roles = [role]
  user.save!
  log_in(user)
end

Given /^user with (\w+) "(.*?)" has role "(.*?)"$/ do |key, value, role_name|
  user = find_user key, value
  user.roles << Role.find_by_name(role_name)
end

Given /^there exists a user with cwis "(.*?)" and name "(.*?)"$/ do |arg1, arg2|
  names = arg2.split(' ')
  user = User.create(identifier: arg1, username: arg1+"_test_username", firstname: names[0], lastname: names[1..-1].join(' '), provider: 'dtu_cas')   
  account = Dtubase::Account.new
  account.cwis = arg1
  account.firstname = user.firstname
  account.lastname = user.lastname
  Dtubase::Account.stub(:find_by_username).with(user.username).and_return(account)
end

Given /^I'm logged in(?: as user with no role)?$/ do
  arg1 = "No name user"
  names = arg1.split(' ')
  user = User.create(identifier: arg1, username: arg1+"_test_username", firstname: names[0], lastname: names[1..-1].join(' '), provider: 'dtu_cas')   
  log_in(user)  
end

Given /^I log in$/ do
  steps %{
    Given I'm logged in
  }
end

Given /^I(?:'m| am) logged in by (DTU CAS|Public CAS)$/ do |auth_name|
  map = { 
    'DTU CAS' => 'dtu_cas', 
    'Public CAS' => 'public_cas' 
  }

  if map.has_key? auth_name
    user = User.create(
      :identifier => '1234', 
      :username => 'johndoe', 
      :provider => map[auth_name], 
      :firstname => 'John', 
      :lastname => 'Doe', 
      :email => 'john_doe@example.com'
    )
    log_in user
  end
end

Given /^I(?:'m| am) a walk-in user$/ do
  ApplicationController.stub(:walk_in_request?).and_return(true)
end

def log_in(user)
  OmniAuth.config.test_mode = true

  visit('/')  

  # Click the login link that will take user to auth provider selection
  click_link 'Log in' if page.has_css? '#util-links a', :text => 'Log in'

  # Select auth provider by clicking radio buttn and do necessary stuff for each auth provider
  case user.provider
  when 'dtu_cas'
    mock_dtu_cas user
    choose 'DTU Campus Login'
  end
  
  # Click final login button
  click_button 'Log in'
end

Given /^I log out$/ do
  click_link 'Log out'
end

def mock_dtu_cas user
  OmniAuth.config.add_mock(:dtu_cas, {
    :uid => user.username,
    :info => { :name => user.to_s },  
    :extra => {
      :user => user.username
    }
  })

  Dtubase.config.test_mode = true
  Dtubase.config.add_mock(user.username, <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<root>
  <account matrikel_id="#{user.identifier}" cprnr="XXXXXX-XXXX" last_updated="" last_updated_all="" auth_gateway="unix" fk_createdby_matrikel_id="1" username="#{user.username}" sysadm="0" firstname="#{user.firstname}" lastname="#{user.lastname}" title="" company_address="" company_address_is_primary="0" company_address_is_hidden="1" temporary_address="" temporary_address_is_primary="0" temporary_address_is_hidden="1" private_homepage_url="" official_email_address="" official_picture_url="" official_picture_hide_in_cn="1" sms_provider="" sms_phone="" library_pincode="" library_username="" primary_profile_id="" preferred_language="en" hide_private_address="0" note="" dtu_initials="" has_active_profile="1" external_Phonebook="1" external_Portalen="1" external_Biblioteket="1" nextOfKinName="" nextOfKinRelation="" nextOfKinTelephone="">
    <private_address address_id="" hide_address="0" is_primary_address="0" is_secret_address="0" street="YYYYYYYYYYY, ZZZ" building="" room="" zipcode="XXXX" city="YYYYYY" country="" phone1="" phone2="" phone3="" mobile_phone="" fax="" picture_url="" homepage_url="" email_address="" institution_name="" institution_number="" title="" location_map_name="" location_map_coordinates="" />
    <profile_employee fk_profile_id="" fk_createdby_matrikel_id="" last_updated="" fk_matrikel_id="" fk_orgunit_id="58" active="1" employee_number="" position_title="Programmør" position_title_uk="Programmer" note="" mail_servername="" mail_servertype="" external_Portalen="1" external_Phonebook="1" external_Biblioteket="1" ReferenceMatrikelId="" ReferenceTypeId="3">
      <date_created>2010-07-07T13:27:00</date_created>
      <dt_employment_start>2010-09-01T00:00:00</dt_employment_start>
      <address address_id="" hide_address="0" is_primary_address="1" is_secret_address="0" street="" building="101D" room="" zipcode="" city="" country="dk" phone1="" phone2="" phone3="" mobile_phone="" fax="" picture_url="" homepage_url="" email_address="sego@dtic.dtu.dk" institution_name="" institution_number="" title="" location_map_name="" location_map_coordinates="" />
      <scanpas fk_profile_id="" stiko="3771" stiko_stilling="Programmør" stiko_startdate="2010-09-01T00:00:00" stiko_enddate="2011-03-31T00:00:00" stiko_primary="1" stiko_calcprimary="1" stiko_loenform="2" stiko_inst="55" FacultyKey="0" />
    </profile_employee>
    <profile_student fk_profile_id="" phd_scanpas="" fk_createdby_matrikel_id="1" last_updated="2010-08-25T13:20:00" fk_matrikel_id="41453" fk_orgunit_id="stud" active="0" exchange="0" phd="1" open_university="0" ordinary="0" admission="0" stads_userid="" stads_studentcode="" study_line="" study_frame="PHDGÆST02" study_frame2="PH. D." point="0" note="" mail_servername="" mail_servertype="IMAP4" ftp_servername="" ftp_serverport="21" ftp_homedir="/" ftp_username="" Adresseland="" Nationalitet="DK" ApplicationNo="" optagelsesaar="2007" uddannelse_dk="" uddannelse_uk="" retning_dk="" retning_uk="">
      <date_end>2008-02-18T00:00:00</date_end>
      <date_created>2007-06-12T03:47:00</date_created>
      <date_archived>2008-02-19T05:00:00</date_archived>
      <ramme_start_dato>2007-06-11T00:00:00</ramme_start_dato>
      <address address_id="" hide_address="1" is_primary_address="0" is_secret_address="0" street="" building="" room="" zipcode="" city="" country="DK" phone1="" phone2="" phone3="" mobile_phone="" fax="" picture_url="" homepage_url="" email_address="" institution_name="" institution_number="" title="studerende" location_map_name="" location_map_coordinates="" />
    </profile_student>
  </account>
</root>
  EOF
  )  
  
end  

