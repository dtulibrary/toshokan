module IsiHelper

  def isi_url document
    @isi_url ||= document.backlinks.select {|bl| bl.include? 'isiknowledge'}.first
  end

  def render_link_to_isi? document
    isi_url(document).present?
  end

  def link_to_isi document
    return unless isi_url(document)

    link_to( image_tag('isi_logo2.png'), isi_url(document),
      :class  => 'isi-backlink',
      :target => '_blank',
      :title  => t('toshokan.tools.metrics.isi.title'))

  end
end
