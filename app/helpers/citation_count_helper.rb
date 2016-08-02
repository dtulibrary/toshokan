module CitationCountHelper
  def render_citation_count_text?(document)
    !citation_count_identifiers(document).empty?
  end

  def citation_count_text(document, opts = {})
    identifiers = citation_count_identifiers(document)
    api_path = Rails.configuration.getit[:url] + '/citation_count'
    content_tag(:div, '', id: 'citation_count_lookup', data: identifiers.merge(api: api_path))
  end

  def citation_count_identifiers(document)
    mendeley_identifiers(document).keep_if { |k, _| k.in? [:doi, :scopus, :pmid] }
  end
end
