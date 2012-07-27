class Dtubase::GuestProfile
  include HappyMapper
  tag 'profile_guest'
  attribute :id, String, :tag => 'fk_profile_id'
  attribute :email, String, :tag => 'email_address', :xpath => 'address/@email_address'
  attribute :active, Boolean
  def kind
    'guest'
  end
  def org_id
    nil
  end
end
