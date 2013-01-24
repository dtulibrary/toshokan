class AuthProviderController < ApplicationController
  skip_before_filter :authenticate

  def index
    session[:return_url] ||= params[:return_url]
    @auth_providers = [:dtu_cas, :dtu_walkin, :public]
  end

  def create
    auth_provider = params[:auth_provider]
    if auth_provider
      cookies.permanent[:auth_provider] = auth_provider if params[:sticky] and can? :remember, :auth_provider
      session[:auth_provider] = auth_provider
      return_url = session[:return_url] || root_path
      redirect_to return_url
    end
  end
end
