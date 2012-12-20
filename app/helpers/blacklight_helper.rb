module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # Override blacklight document actions to exclude 'Folder' and 'Bookmarks'
  # and instead render 'Tagging' functionality
  def render_index_doc_actions (document, options={})
    content = []
    content << render_tag_control(document) if has_user_authentication_provider? && current_user
    content_tag("div", content.join("\n").html_safe, :class=>"documentFunctions")
  end

  # Override blacklight document actions in 'show' view to
  # exclude 'Folder' and 'Bookmarks' and instead render 'Tagging' functionality
  def render_show_doc_actions(document=@document, options={})
    content = []
    content << tag_control(document) if has_user_authentication_provider? && current_user
    content_tag("div", content.join("\n").html_safe, :class=>"documentFunctions")
  end

  # Override blacklight citation_title since it doesn't handle multi-valued title field
  def citation_title document
    title = document[blacklight_config.show.html_title]
    (title.kind_of? Array) ? title.first : title
  end
end
