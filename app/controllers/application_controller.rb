require 'netaddr'
require 'uri'

class ApplicationController < ActionController::Base
  include Blacklight::Controller

  layout 'blacklight'

  rescue_from ActionController::RoutingError, :with => :render_not_found

  protect_from_forgery

  before_filter :set_locale
  before_filter :log_user_info
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

  def log_user_info
    logger.info "session_id: #{request.session_options[:id]}"
    logger.info "current_user.id: #{current_user.id}"

    logger.info "current_user: #{current_user.inspect}" if current_user.authenticated?
    logger.info "original_user: #{original_user.inspect}" if current_user.impersonating?
  rescue Exception => e
    logger.warn "Could not log user info: #{e.class} #{e.message}"
  end

  # Authenticate users if certain criteria are met.
  # - No authentication will be done if user is already logged in.
  # - Force authentication if the shunting cookie indicates
  #   that last successful login was via CAS or
  #   if the user originates from a DTU Campus ip address
  # - Otherwise authentication is optional
  def authenticate

    # This suppresses the log in suggestion on subsequent
    # request if the user clicks "No"
    if params[:stay_anonymous]
      cookies[:shunt_hint] = 'anonymous'
      logger.info "Suppressing log in suggestion"
      redirect_to url_for(params.except!(:stay_anonymous))
    end

    if params[:public]
      cookies[:shunt_hint] = 'public'
      redirect_to url_for(params.except!(:public))
    end

    if should_force_authentication
      force_authentication
    end
  end


  def should_force_authentication
    # We force authentication in two situations:
    #  - The user has successfully logged in via DTU Cas before (i.e. the shunt cookie is set to 'dtu')
    #  - The user has never been logged in before  (i.e. the shunt hint cookie is not set), and originates from an identified campus IP
    can?(:login, User) && (cookies[:shunt] == 'dtu') || (!cookies[:shunt_hint] && campus_request? && !params[:dlib])
  end

  def force_authentication(params = {})
    logger.info "Forcing authentication: cookies[:shunt]:#{cookies[:shunt]}, cookies[:shunt_hint]:#{cookies[:shunt_hint]}, campus_request?:#{campus_request?}"
    params[:url] = request.url
    logger.info "params: #{params}"
    redirect_to new_user_session_path(params)
  end

  def require_authentication
    logger.info "Require authentication for params:#{params}. cookies[:shunt]:#{cookies[:shunt]}, cookies[:shunt_hint]:#{cookies[:shunt_hint]}"
    if cookies[:shunt]
      force_authentication
    else
      redirect_to authentication_required_path(:url => request.url, :dlib => params[:dlib])
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
  rescue => e
    logger.info "request.remote_ip: #{request.remote_ip} is not an ip address. #{e.class}: #{e.message}"
    false
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
                 when current_user.internal? || current_user.impersonating?
                   'dtic'
                 when current_user.dtu?
                   case
                   when current_user.employee?
                     'dtu_staff'
                   when current_user.student?
                     'dtu_student'
                   else
                     'dtu'
                   end
                 when current_user.authenticated?
                   case
                   when current_user.walk_in?
                     'walk_in_authenticated'
                   else
                     'public_authenticated'
                   end
                 else
                   case
                   when current_user.walk_in?
                     'walk_in_anonymous'
                   else
                     'public_anonymous'
                   end
                 end
    set_google_analytics_dimension_or_metric 'dimension1', user_group
  rescue Exception => e
    logger.warn "Could not set GA metrics. #{e.class}: #{e.message}"
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

  def bad_request
    raise 'Bad request'
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

  def show_nal_locations?
    @show_nal_locations
  end

  helper_method :show_nal_locations?

  def show_nal_locations= value
    @show_nal_locations = value
  end

end
