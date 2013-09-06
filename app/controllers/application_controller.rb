require 'netaddr'
require 'uri'

class ApplicationController < ActionController::Base
  include Blacklight::Controller

  layout 'blacklight'

  rescue_from ActionController::RoutingError, :with => :render_not_found

  protect_from_forgery

  before_filter :set_locale
  before_filter :authenticate
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
  # - Force authentication if the shunting cookie indicates
  #   that last successful login was via CAS or
  #   if the user originates from a DTU Campus ip address
  # - Otherwise authentication is optional
  def authenticate
    if params[:stay_anonymous]
      cookies[:shunt_hint] = 'anonymous'
      redirect_to url_for(params.except!(:stay_anonymous))
    end

    unless session[:user_id] || current_user.impersonating?
      if (cookies[:shunt] == 'dtu') || (campus_request? && !cookies[:shunt_hint])
        session[:return_url] ||= request.url
        redirect_to polymorphic_url(:new_user_session)
      end
    end
  end

  # Disable rendering the searchbar in the header
  def disable_header_searchbar
    @disable_header_searchbar = true
  end

  helper_method :guest_user, :current_or_guest_user

  def current_user
    user = logged_in_user || guest_user

    user.impersonating = case
                         when session[:impersonate_student]
                           'student'
                         when session[:impersonate_employee]
                           'employee'
                         when session[:original_user_id]
                           true
                         else
                           false
                         end

    user.internal      = internal_request?
    user.campus        = campus_request?
    user.walk_in       = case
                         when user.impersonating?
                           session[:impersonate_walk_in]
                         else
                           walk_in_request?
                         end

    if user.orders_enabled? != orders_enabled_request?
      user.orders_enabled = orders_enabled_request?
      @current_ability = nil
    end

    user
  end

  def logged_in_user
    if session[:user_id]
      user = User.find_by_id session[:user_id]
      return user
    end
  end

  def original_user
    User.find_by_id(session[:original_user_id])
  end
  helper_method :original_user

  def walk_in_request?
    request_matches_ips? Rails.application.config.auth[:ip][:walk_in]
  end

  def campus_request?
    request_matches_ips? Rails.application.config.auth[:ip][:campus]
  end

  def internal_request?
    request_matches_ips? Rails.application.config.auth[:ip][:internal]
  end

  def orders_enabled_request?
    Rails.application.config.orders[:enabled] || request_matches_ips?(Rails.application.config.orders[:enabled_ips])
  end

  def request_matches_ips? ips
    remote = NetAddr::CIDR.create request.remote_ip
    remote_matches_ips? remote, ips
  end

  def remote_matches_ips? remote, ips
    result = false
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
    result
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
