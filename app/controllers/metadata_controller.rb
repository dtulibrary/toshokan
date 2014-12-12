class MetadataController < ApplicationController
  def show
    (deny_access and return) unless can? :view, :metadata

    content = HTTParty.get("#{Rails.application.config.metadata[:url]}?dedup=#{params[:id]}")
    render :html => content.html_safe, :layout => nil and return
  end
end
