module CoverImageHelper

  def render_cover_image document
    image_tag cover_images_path(CoverImages.extract_identifier document), :class => 'media-object cover-image'
  end

end
