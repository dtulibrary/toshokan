module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # Save function area for search results 'index' view, normally
  # renders next to title. Includes just 'Folder' by default.
  def render_index_doc_actions (document, options={})   
    content = []
    content << tag_control(document)
    content_tag("div", content.join("\n").html_safe, :class=>"documentFunctions")
  end

  # Save function area for item detail 'show' view, normally
  # renders next to title. By default includes 'Folder' and 'Bookmarks'
  def render_show_doc_actions(document=@document, options={})
    content = []
    content << tag_control(document)
    content_tag("div", content.join("\n").html_safe, :class=>"documentFunctions")
  end

end