class ApplicationController < ActionController::Base
  include Blacklight::Controller

  rescue_from ActionController::RoutingError, :with => :render_not_found

  protect_from_forgery

  before_filter :authenticate_conditionally

  # Will only do authentication if the user is not allowed to act anonymously
  def authenticate_conditionally
    authenticate unless can? :be_anonymous, User
  end

  # Will always do authentication
  def authenticate
    unless session[:user_id]
      session['return_url'] = request.url
      logger.debug request.url
      # Recreate user abilities on each login
      @current_ability = nil
      redirect_to polymorphic_url(:new_user_session)
    end
  end

  helper_method :guest_user, :current_or_guest_user

  def current_user
    if session[:user_id]
      user = User.find(session[:user_id])
      user.impersonating = session.has_key? :original_user_id if user
      return user
    end
  end

  def guest_user
    User.new
  end

  def current_or_guest_user
    current_user || guest_user
  end

  # Call this to bail out quickly and easily when something is not found.
  # It will be rescued and rendered as a 404
  def not_found
    raise ActionController::RoutingError.new 'Not found'
  end

  # Render 401
  def deny_access
    render(:file => 'public/401', :format => :html, :status => :unauthorized, :layout => nil)
  end

  # Render a 404 response. This should not be called directly. Instead you should call #not_found
  # which will raise exception, rescue it and call this render method
  def render_not_found
    render :file => 'public/404', :format => :html, :status => :not_found, :layout => nil
  end
end
