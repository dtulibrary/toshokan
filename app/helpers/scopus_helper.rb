module ScopusHelper

  def scopus_url document
    @scopus_url ||= document.backlinks.select {|bl| bl.include? 'scopus.com/inward' }.first
  end

  def render_link_to_scopus? document
    scopus_url(document).present?
  end

  def link_to_scopus document
    return unless scopus_url(document).present?

    link_to(image_tag('scopus_logo.png', style: 'width: 64px; height: 18px;'), scopus_url(document),
      :class  => 'scopus-backlink',
      :target => '_blank',
      :title  => t('toshokan.tools.metrics.scopus.title'))
    .concat(content_tag(:div, {id: 'elsevier_citation_count', class: 'badge hide'}) do
      link_to("","", {style: 'color: inherit; text-decoration: inherit;', target: '_blank'})
    end)
  end
end
