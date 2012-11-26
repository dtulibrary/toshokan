class Tag < ActiveRecord::Base
  belongs_to :user
  has_many :taggings, :dependent => :destroy
  has_many :subscriptions, :dependent => :destroy

  attr_accessible :name, :shared

  def share
    update_attributes(:shared => true)
  end

  def unshare
    update_attributes(:shared => false)
  end

end