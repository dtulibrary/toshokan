module AdvancedSearchHelper 
  def advanced_search_fields
    blacklight_config.search_fields.reject do |field_name, field|
      field_name == 'all_fields' || !field.solr_local_parameters[:qf]
    end
  end
end
