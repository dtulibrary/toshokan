# -*- encoding : utf-8 -*-

class Tag < ActiveRecord::Base
  belongs_to :user
  has_many :taggings, :dependent => :destroy
  has_many :bookmarks, :through => :taggings
  has_many :subscriptions, :dependent => :destroy

  attr_accessible :name, :shared
  attr_accessor :count

  validates :name, :presence => true,
                   :length => { :in => 1..255 }
  validate :name_not_reserved

  def self.reserved_tag_prefix
    '✩'
  end

  def self.reserved_tag_all
    reserved_tag_prefix + I18n.t('toshokan.tags.all')
  end

  def self.reserved_tag_untagged
    reserved_tag_prefix + I18n.t('toshokan.tags.untagged')
  end

  def self.reserved_tags
    [reserved_tag_all, reserved_tag_untagged]
  end

  def self.reserved?(tag_name)
    tag_name && tag_name.starts_with?(Tag.reserved_tag_prefix)
  end

  private

  def name_not_reserved
    if Tag.reserved?(name)
      errors.add :name, "Name can not start with #{Tag.reserved_tag_prefix}"
    end
  end
end
