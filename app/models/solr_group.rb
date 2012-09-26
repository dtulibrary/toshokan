# -*- encoding : utf-8 -*-
class SolrGroup 
  extend ActiveModel::Naming

  def initialize(group_values, solr_response)
    
    @group_values = group_values
    @solr_response = solr_response

  end  
  
  def id
    @group_values["groupValue"]
  end

  def [] key
    @group_values["doclist"]["docs"].first[key]
  end    
  
  def get(key, options = {})
    self[key]
  end  

  def has?(key)
    self[key].present?
  end  
  
  def to_param
    id
  end  
  
  def export_formats
    {}
  end  

end  