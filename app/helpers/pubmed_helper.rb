module PubmedHelper

  def pubmed_url document
    return nil if document['pubmed_url_ssf'].blank?
    "#{document['pubmed_url_ssf'].first}?otool=#{Rails.application.config.pubmed[:dtu_id]}"
  end

  def render_link_to_pubmed? document
    pubmed_url(document)
  end

  def link_to_pubmed document
    return unless pubmed_url(document)

    link_to( image_tag('pubmed_logo2.png'), pubmed_url(document),
      :class  => 'pubmed-backlink',
      :target => '_blank',
      :title  => t('toshokan.tools.metrics.pubmed.title'))
      
  end
end
