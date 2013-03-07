module AdvancedSearchHelper 
  def advanced_search_fields
    blacklight_config.search_fields
  end

  def advanced_search_fields_with_content local_params = params || {}
    advanced_search_fields.reject do |field_name, field|
      field_name_sym = field_name.to_sym
      !local_params[field_name_sym] || local_params[field_name_sym].blank?
    end
  end

  # Return a hash containing modified q param along with
  # value params for each references advanced search field.
  # NOTE: Keys in returned hash are symbols since session[:search]
  #       doesn't have indifferent access and expects symbols.
  #       The same goes for local_params keys, since sometimes
  #       session[:search] is given as local_params.
  def advanced_query_params local_params = params || {}
    nested_queries = []
    user_queries = {}
    result = {}
    
    # Build a nested query for each non-empty configured field
    advanced_search_fields_with_content(local_params).each do |field_name, field|
      field_name_sym = field_name.to_sym
      user_queries[field_name] = local_params[field_name_sym]
      if field.solr_local_parameters
        qf = field.solr_local_parameters[:qf]
        pf = field.solr_local_parameters[:pf] || field.solr_local_parameters[:qf]
        nested_queries << "_query_:\"{!edismax qf=#{qf} pf=#{pf} v=$#{field_name}}\""
      else
        # Using default qf and pf
        nested_queries << "_query_:\"{!edismax v=$#{field_name}}\""
      end 
    end 

    # Modify params to include a value field for each non-empty advanced search field
    unless nested_queries.empty?
      match_mode = local_params[:match_mode] || 'all'
      joiner = (match_mode == 'all') ? ' AND ' : ' OR '
      orig_q = local_params[:q]
      q = (orig_q && !orig_q.blank?) ? orig_q : '*:*'
      result[:q] = "#{q} AND (#{nested_queries.join joiner})"

      user_queries.each do |name, value|
        result[name] = value
      end 
    end 

    result
  end 

  def advanced_search?
    session[:advanced_search]
  end

  def render_advanced_search_button
    button_tag(
      ("%s %s" % [t('toshokan.header.search'), content_tag('i', '', :class => 'icon-search icon-white')]).html_safe,
      :id => 'advanced_search',
      :value => 'advanced_search',
      :class => 'btn btn-primary'
    )
  end
end
