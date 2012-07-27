class Dtubase::StudentProfile
  include HappyMapper
  tag 'profile_student'
  attribute :id, String, :tag => 'fk_profile_id'
  attribute :email, String, :tag => 'email_address', :xpath => 'address/@email_address'
  attribute :active, Boolean
  def kind
    'student'
  end
  def org_id
    nil
  end
end
