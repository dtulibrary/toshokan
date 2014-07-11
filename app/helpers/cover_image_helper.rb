module CoverImageHelper

  def render_cover_image document
    content_tag('div', '', :'data-href' => cover_images_path(CoverImages.extract_identifier document), :class => 'media-object cover-image hidden') unless Rails.application.config.cover_images[:stub]
  end

end
