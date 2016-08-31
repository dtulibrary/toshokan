module AltmetricHelper

  def render_altmetric_badge?(document)
    current?(document) && recognized_identifiers?(document)
  end

  def altmetric_badge(document, opts={})
    content_tag(:div, {id: 'altmetric_citation_count_wrapper', style: 'display: none'}) do
      link_to("") do
        image_tag('altmetric.svg', style: 'width: 64px; height: 12px;')
      end
      .concat(content_tag(:div, {id: 'altmetric_citation_count', class: 'badge', style: 'display: none'}) do
        link_to("","", {style: 'color: inherit; text-decoration: inherit;'})
      end)
    end
  end

  def recognized_identifiers?(doc)
    # if there is an intersection '&' here,
    # then we have one or more of these id types
    (mendeley_identifiers(doc).keys & [:doi, :pmid, :arxiv]).present?
  end

  def current?(document)
    date = document['pub_date_tis'].try(:first)
    date.present? && date.try(:to_i) > 2010
  end
end
