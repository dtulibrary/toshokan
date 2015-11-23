module ComponentHelper
  include Blacklight::ComponentHelperBehavior

  # Override blacklight document actions to exclude 'Folder' and 'Bookmarks'
  # and instead render 'Tagging' functionality
  def render_index_doc_actions (document, options={})
    wrapping_class = options.delete(:wrapping_class) || "index-document-functions"

    content = []
    content << render_tag_control(document) if can? :tag, Bookmark
    content_tag("div", content.join("\n").html_safe, :class => wrapping_class) unless content.empty?
  end
end
