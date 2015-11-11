module IsiHelper

  def isi_url document
    return nil if document['isi_url_ssf'].blank?
    document['isi_url_ssf'].first
  end

  def should_render_link_to_isi? document
    isi_url(document)
  end

  def link_to_isi document
    return unless isi_url(document)

    link_to( image_tag('isi_logo2.png'), isi_url(document),
      :class  => 'isi-backlink',
      :target => '_blank',
      :title  => t('toshokan.tools.metrics.isi.title'))
      
  end
end
