module CitationCountHelper
  def render_citation_count_text?(document)
    true
  end

  def citation_count_text(document, opts={})
    identifiers = mendeley_identifiers(document)
    content_tag(:div, "", { :"data" => { :"citation-count" => '', :"doi" => identifiers[:doi] } })
  end
end
