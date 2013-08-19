require 'netaddr'
require 'uri'

class ApplicationController < ActionController::Base
  include Blacklight::Controller

  layout 'blacklight'

  rescue_from ActionController::RoutingError, :with => :render_not_found

  protect_from_forgery

  before_filter :set_locale
  before_filter :authenticate
  before_filter :check_walk_in_only
  before_filter :set_google_analytics_dimensions_and_metrics
  before_filter :set_search_history

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def current_locale
    I18n.locale
  end

  helper_method :current_locale

  # Authenticate users if certain criteria are met.
  # - No authentication will be done if user is already logged in.
  # - No authentication will be done if an authentication provider
  #   has not been chosen. This will also check for sticky choice
  #   from :auth_provider cookie.
  def authenticate
    # Use sticky auth provider if it isn't already set in session
    session[:auth_provider] ||= cookies[:auth_provider]

    # No authentication if user is already logged in
    unless session[:user_id]
      # Only do authentication if an auth provider has been chosen
      if session[:auth_provider]
        # Return URL could be set by the authentication provider selection page
        session[:return_url] ||= request.url
        # Recreate user abilities on each login
        @current_ability = nil
        redirect_to polymorphic_url(:new_user_session)
      end
    end
  end

  # Disable rendering the searchbar in the header
  def disable_header_searchbar
    @disable_header_searchbar = true
  end

  def check_walk_in_only
    if Rails.application.config.walk_in[:only]
      redirect_to come_back_later_url unless current_user.walk_in
    end
    session.delete :come_back_later
  end

  helper_method :guest_user, :current_or_guest_user

  def current_user
    user = logged_in_user || guest_user
    user.walk_in = walk_in_request?
    user.internal = internal_request?

    if user.orders_enabled? != orders_enabled_request?
      user.orders_enabled = orders_enabled_request?
      @current_ability = nil
    end

    return user
  end

  def logged_in_user
    if session[:user_id]
      user = User.find session[:user_id]
      user.impersonating = session.has_key? :original_user_id if user
      return user
    end
  end

  def walk_in_request?
    request_matches_ips? Rails.application.config.walk_in[:ips]
  end

  def orders_enabled_request?
    Rails.application.config.orders[:enabled] || request_matches_ips?(Rails.application.config.orders[:enabled_ips])
  end

  def internal_request?
    request_matches_ips? Rails.application.config.internal[:ips]
  end

  def request_matches_ips? ips
    result = false
    remote = NetAddr::CIDR.create request.remote_ip
    ips.each do |ip|
      if ip.include? '-'
        # Range
        lower, upper = NetAddr::CIDR.create($1), NetAddr::CIDR.create($2) if ip =~ /^(\S*)\s*-\s*(\S*)$/
        result ||= (lower..upper).include? remote
      elsif ip.include? '*'
        # Wildcard
        result ||= NetAddr.wildcard(ip).matches? remote
      else
        # Standard
        result ||= NetAddr::CIDR.create(ip).matches? remote
      end
    end
    return result
  end

  def guest_user
    User.new
  end

  def current_or_guest_user
    current_user
  end

  def set_google_analytics_dimensions_and_metrics
    user_group = case
                 when current_user.internal?
                   'dtic'
                 when current_user.walk_in?
                   'walk_in_anonymous'
                 else
                   'public_anonymous'
                 end
    set_google_analytics_dimension_or_metric 'dimension1', user_group
  end

  def set_google_analytics_dimension_or_metric name, value
    GoogleAnalytics.set_custom_variable name, value
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
  def render_not_found(exception)
    render :file => 'public/404', :format => :html, :status => :not_found, :layout => nil
  end

  # strip scheme, host and port from url to ensure that it is
  # safe to redirect to (even if we get it from the client)
  def only_path(url)
    URI.parse(url).tap {|uri|
      uri.scheme = nil
      uri.host = nil
      uri.port = nil
    }.to_s
  end

  def default_url_options options = {}
    { :locale => I18n.locale }
  end

  def set_search_history
    if can? :view, :search_history
      @search_history = current_user.searches.order("created_at DESC").limit(Blacklight::Catalog::SearchHistoryWindow)
    else
      @search_history = searches_from_history
    end
  end
end
