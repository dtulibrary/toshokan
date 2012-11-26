class Tagging < ActiveRecord::Base
  belongs_to :tag

  attr_accessible :solr_id, :tag
end