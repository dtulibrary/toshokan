module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # Save function area for search results 'index' view, normally
  # renders next to title. Includes just 'Folder' by default.
  def render_index_doc_actions (document, options={})   
    content = []
    content << tag_control(document)
    content_tag("div", content.join("\n").html_safe, :class=>"documentFunctions")
  end

end