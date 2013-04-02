class CoverImagesController < ApplicationController

  def show 
    id = params[:id]
    response = CoverImages.get id
    if response.code == 404
      redirect_to view_context.image_path('invisible_cover_image.png')
    else
      send_data response.body, :status => response.code
    end
  end

end
