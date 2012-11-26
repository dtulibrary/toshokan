class SolrDocumentPointer < ActiveRecord::Base
  attr_accessible :solr_id

  validates :solr_id, :uniqueness => true, :presence => true

end
