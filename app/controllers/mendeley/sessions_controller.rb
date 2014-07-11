class Mendeley::SessionsController < ApplicationController

  def new
    url = session[:return_url] = params[:url] || '/'
    redirect_to "/auth/mendeley?#{{ :url => url }.to_query }"
  end

  def setup
    render :text => "Omniauth setup phase.", :status => 404
  end

  def create
    # extract authentication data
    auth = request.env["omniauth.auth"]
    session[:mendeley_access_token] = auth.credentials
    redirect_to params[:url] || session.delete(:return_url) || root_path
  end


end
