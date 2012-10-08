module CoverImageHelper

  def render_cover_image document
    image_tag CoverImages.url_for(document), :class => 'cover-image'
  end

end
