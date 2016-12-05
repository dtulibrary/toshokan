module IsiHelper

  def isi_url document
    @isi_url ||= document.backlinks.select {|bl| bl.include? 'isiknowledge'}.first
  end

  def render_link_to_isi? document
    isi_url(document).present?
  end

  def link_to_isi document
    return unless isi_url(document)

    link_to("Web of Science", isi_url(document),
      :class  => 'isi-backlink',
      :target => '_blank',
      :title  => t('toshokan.tools.metrics.isi.title'))
    .concat(content_tag(:span) do
      " "
    end)
    .concat(content_tag(:div, {id: 'web_of_science_citation_count', class: 'badge hide'}) do
      link_to("","", {style: 'color: inherit; text-decoration: inherit;', target: '_blank', title: t('toshokan.tools.metrics.isi.title')})
    end)
  end
end
