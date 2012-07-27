class Dtubase::EmployeeProfile
  include HappyMapper
  tag 'profile_employee'

  attribute :id, String, :tag => 'fk_profile_id'
  attribute :org_id, String, :tag => 'fk_orgunit_id'
  attribute :email, String, :tag => 'email_address', :xpath => 'address/@email_address'
  attribute :active, Boolean
  def kind
    'employee'
  end
end
