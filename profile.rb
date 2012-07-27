class Profile < ActiveRecord::Base
  attr_accessible :active, :email, :identifier, :org_id, :user_id, :kind
end
