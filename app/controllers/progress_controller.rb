class ProgressController < ApplicationController
  def show
    respond_to do |format|
      format.json do
        p = Progress.find_by_name(params[:name]) || not_found
        render :json => p.to_json
      end
    end
  end
end
