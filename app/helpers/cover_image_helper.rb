module CoverImageHelper

  def render_cover_image document
    content_tag('div', '', :'data-href' => cover_images_path(CoverImages.extract_identifier document), :class => 'cover-image pull-right hide') unless Rails.application.config.cover_images[:stub]
  end

end
