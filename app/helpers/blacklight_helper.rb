module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # Override blacklight document actions to exclude 'Folder' and 'Bookmarks'
  # and instead render 'Tagging' functionality
  def render_index_doc_actions (document, options={})
    wrapping_class = options.delete(:wrapping_class) || "index-document-functions"

    content = []
    content << render_tag_control(document) if can? :tag, Bookmark
    content_tag("div", content.join("\n").html_safe, :class => wrapping_class) unless content.empty?
  end

  # Override blacklight citation_title since it doesn't handle multi-valued title field
  def citation_title document
    title = document[blacklight_config.show.title_field]
    (title.kind_of? Array) ? title.first : title
  end

  # used in the catalog/_show/_default partial
  def document_show_fields document=nil    
    filter_fields blacklight_config.show_fields, document
  end

  ##
  # Index fields to display for a type of document
  def index_fields document=nil
    filter_fields blacklight_config.index_fields, document
  end

  def filter_fields fields, document=nil
    filters = field_filters
    fields.select do |field_name, field| 
      filters.select { |filter| filter.call(field, document)}.length == filters.length      
    end
  end

  def field_filters
    filters = []
    
    # some fields are only for certain document types
    filters << Proc.new do |field, document|
      doc_format = document['format'] || ""      
      field.format.nil? || field.format.include?(doc_format)
    end 

    # do not show keywords from iel in public version
    filters << Proc.new do |field, document|
      !(field.field == "keywords_ts" && document.has_key?("source_ss") && document["source_ss"].include?("iel") && (can? :search, :public))
    end

    filters
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

  def field_suppressed? document, solr_field
    suppressed = false
    if solr_field.suppressed_by
      solr_field.suppressed_by.each do |field_name|
        suppressed ||= document[field_name]
      end
    end
    suppressed
  end
  
  ##
  # Renders a single facet item
  # DTU override - to ensure non-relevant access facets are hidden
  def render_facet_item(solr_field, item)
    if facet_in_params?(solr_field, item.value)
      render_selected_facet_value(solr_field, item)          
    elsif solr_field == 'fulltext_availability_ss' && !display_online_access_facet?(item.value)
      nil
    else
      render_facet_value(solr_field, item)
    end
  end
end
