class ApplicationController < ActionController::Base
  include Blacklight::Controller

  protect_from_forgery

  before_filter :authenticate

  def authenticate
    unless session[:user_id]
      session['return_url'] = request.url
      redirect_to polymorphic_url(:new_user_session)
    end
  end

  def current_user
    user = User.find(session[:user_id])
    user.impersonating = session.has_key? :original_user_id
    return user
  end

end
