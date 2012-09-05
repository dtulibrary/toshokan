module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # Override blacklight document actions to exclude 'Folder' and 'Bookmarks'
  # and instead render 'Tagging' functionality
  def render_index_doc_actions (document, options={})   
    content = []
    content << tag_control(document)
    content_tag("div", content.join("\n").html_safe, :class=>"documentFunctions")
  end

  # Override blacklight document actions in 'show' view to
  # exclude 'Folder' and 'Bookmarks' and instead render 'Tagging' functionality
  def render_show_doc_actions(document=@document, options={})
    content = []
    content << tag_control(document)
    content_tag("div", content.join("\n").html_safe, :class=>"documentFunctions")
  end

end