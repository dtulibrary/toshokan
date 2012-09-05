class ApplicationController < ActionController::Base
  include Blacklight::Controller

  protect_from_forgery

  before_filter :authenticate

  def authenticate
    unless session[:user_id]
      session['return_url'] = request.url
      # Recreate user abilities on each login
      @current_ability = nil
      redirect_to polymorphic_url(:new_user_session)
    end
  end

  def current_user
    user = User.find(session[:user_id])
    user.impersonating = session.has_key? :original_user_id
    return user
  end

  # Render 401
  def deny_access
    render(:file => 'public/401', :format => :html, :status => :unauthorized, :layout => nil)
  end
end
