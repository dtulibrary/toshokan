module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def presenter_class
    blacklight_config.document_presenter_class
  end

  # Search History and Saved Searches display
  def link_to_search_history_item(params, html="")
    begin 
      params.delete(:t)      
      link_to(raw(html+render_search_to_s(params)), catalog_index_path(params)).html_safe
    rescue
      Rails.logger.warn("Search url could not be rendered from #{params.inspect}")  
      ""
    end
  end

  def should_render_index_field? document, solr_field
    !field_suppressed?(document, solr_field) && super
  end

  def should_render_show_field? document, solr_field
    !field_suppressed?(document, solr_field) && super
  end

end
