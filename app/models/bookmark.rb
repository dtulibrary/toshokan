# -*- encoding : utf-8 -*-
class Bookmark < ActiveRecord::Base

  belongs_to :user
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings, :dependent => :destroy
  validates_presence_of :user_id, :scope=>:document_id
  attr_accessible :id, :document_id, :title


  def document
    SolrDocument.new SolrDocument.unique_key => document_id
  end

end
