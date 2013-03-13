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

  def render_document_show_field_value args
    value = super
    args[:field] == 'format' ? I18n.t("toshokan.catalog.formats.#{value}") : value
  end

  # used in the catalog/_show/_default partial
  def document_show_fields document=nil    
    show_fields = blacklight_config.show_fields.select { |field_name, field| 
      field.format.nil? || field.format.include?(document['format'])
    }
  end

end
