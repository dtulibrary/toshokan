class CoverImagesController < ApplicationController

  def show 
    id = params[:id]
    response = CoverImages.get id
    send_data response.body, :status => response.code
  end

end
