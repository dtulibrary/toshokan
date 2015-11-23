module CitationHelper

  # This helper was originally in blacklight.
  # It has been removed from blacklight but this app still uses it.
  def citation_title document
    title = document[blacklight_config.show.title_field]
    (title.kind_of? Array) ? title.first : title
  end
end