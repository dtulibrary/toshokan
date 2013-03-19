module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # Override blacklight document actions to exclude 'Folder' and 'Bookmarks'
  # and instead render 'Tagging' functionality
  def render_index_doc_actions (document, options={})
    content = []
    content << render_tag_control(document) if can? :tag, Bookmark
    content_tag("div", content.join("\n").html_safe, :class=>"documentFunctions")
  end

  # Override blacklight citation_title since it doesn't handle multi-valued title field
  def citation_title document
    title = document[blacklight_config.show.html_title]
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
    doc_format = document['format'] unless document.nil?
    doc_format ||= ""
    fields.select { |field_name, field| 
      field.format.nil? || field.format.include?(doc_format)
    }
  end

end
