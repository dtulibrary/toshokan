module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # Save function area for search results 'index' view, normally
  # renders next to title. Includes just 'Folder' by default.
  def render_index_doc_actions (document, options={})   
    content = []
    content << render(:partial => 'catalog/bookmark_control', :locals => {:document=> document}.merge(options)) if has_user_authentication_provider? and current_user
    content << render(:partial => 'catalog/folder_control', :locals => {:document=> document}.merge(options))
    content << tag_control(document)
    content_tag("div", content.join("\n").html_safe, :class=>"documentFunctions")
  end

end