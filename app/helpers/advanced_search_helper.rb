module AdvancedSearchHelper 
  def advanced_search_fields
    blacklight_config.search_fields
  end

  def advanced_search_fields_with_content
    advanced_search_fields.reject do |field_name, field|
      !params[field_name] || params[field_name].blank?
    end
  end

  # Modify params to enable advanced search query
  # - Modifies q param to be AND'ed with AND'ed or OR'ed group of advanced search fields
  # - Adds value field for each advanced search field to params
  # TODO: put in helper
  def add_advanced_query_to_request
    nested_queries = []
    user_queries = {}
    
    # For each non-empty configured field build a nested query
    advanced_search_fields.each do |field_name, field|
      if params[field_name] && !params[field_name].empty?
        user_queries[field_name] = params[field_name]
        if field.solr_local_parameters
          qf = field.solr_local_parameters[:qf]
          pf = field.solr_local_parameters[:pf] || field.solr_local_parameters[:qf]
          nested_queries << "_query_:\"{!edismax qf=#{qf} pf=#{pf} v=$#{field_name}}\""
        else
          # Using default qf and pf
          nested_queries << "_query_:\"{!edismax v=$#{field_name}}\""
        end 
      end 
    end 

    # Modify params to include a value field for each non-empty advanced search field
    unless nested_queries.empty?
      match_mode = params[:match_mode] || 'all'
      joiner = (match_mode == 'all') ? ' AND ' : ' OR '
      orig_q = params[:q]
      q = (orig_q && !orig_q.blank?) ? orig_q : '*:*'
      params[:q] = "#{q} AND (#{nested_queries.join joiner})"

      user_queries.each do |name, value|
        params[name] = value
      end 
    end 
  end 

end
