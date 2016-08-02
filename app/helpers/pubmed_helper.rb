module PubmedHelper

  def pubmed_url document
    @pubmed_url ||= document.backlinks.select {|bl| bl.include? 'nih.gov/pubmed' }.first
  end

  def render_link_to_pubmed? document
    pubmed_url(document).present?
  end

  def link_to_pubmed document
    return unless pubmed_url(document).present?

    link_to( image_tag('pubmed_large.svg'), pubmed_url(document),
      :class  => 'pubmed-backlink',
      :target => '_blank',
      :title  => t('toshokan.tools.metrics.pubmed.title'))

  end
end
