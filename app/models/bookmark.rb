# -*- encoding : utf-8 -*-
class Bookmark < ActiveRecord::Base

  belongs_to :user, polymorphic: true
  belongs_to :document, polymorphic: true
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings, :dependent => :destroy
  validates_presence_of :user_id, :scope=>:document_id

  def document
    document_type.new document_type.unique_key => document_id
  end

  def document_type
    default_document_type
  end

  def default_document_type
    SolrDocument
  end


end
