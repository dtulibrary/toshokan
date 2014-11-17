class Users::SessionsController < ApplicationController
  skip_before_filter :authenticate, :only => [ :setup, :create, :new ]
  before_filter :disable_header_searchbar, :only => [ :switch ]

  # #new is either called by the user clicking login or by the authorize before_filter
  # (due to forced shunting of dtu users).
  def new
    unless can? :login, User
      render(:file => 'public/401', :format => :html, :status => :unauthorized) and return
    end

    case
    when params[:only_dtu]
      logger.info "Overriding shunt cookie with value from params. Using DTU CAS"
      session[:only_dtu] = true
    when params[:public]
      logger.info "Overriding shunt cookie with value from params. Using local user"
      session[:public] = true
    when cookies[:shunt] == 'dtu'
      logger.info "Shunt cookie set to 'dtu'. Shunting directly to DTU CAS"
      session[:only_dtu] = true
    when cookies[:shunt_hint] == 'dtu'
      logger.info "Shunt hint cookie set to 'dtu'. Shunting with hint to DTU CAS"
      session[:prefer_dtu] = true
    when current_user.campus? && !current_user.walk_in?
      logger.info "Campus request. Shunting with hint to DTU CAS"
      session[:prefer_dtu] = true
    end

    # store given return url in session also, since omniauth-cas in
    # test mode does not pass url parameter back to sessions_controller#create
    url = session[:return_url] = params[:url] || '/'

    redirect_to "#{omniauth_path(:cas)}?#{{ :url => url }.to_query }"
  end

  # #setup is called by omniauth before the request phase. We utilize it
  # to setup extra query parameters to Riyosha in the CAS request based on the
  # session
  def setup
    case
    when session.delete(:only_dtu)
      request.env['omniauth.strategy'].options[:login_url] = '/login?only=dtu&template=dtu_user'
    when session.delete(:prefer_dtu)
      request.env['omniauth.strategy'].options[:login_url] = '/login?template=dtu_user'
    when session.delete(:public)
      request.env['omniauth.strategy'].options[:login_url] = '/login?template=local_user'
    else
      request.env['omniauth.strategy'].options[:login_url] = '/login'
    end

    render :text => "Omniauth setup phase.", :status => 404
  end


  # Riyosha redirects the user to #create upon succesful login (since omniauth-cas is
  # configured with #create as callback_url).
  def create
    unless can? :login, User
      render(:file => 'public/401', :format => :html, :status => :unauthorized) and return
    end

    # extract authentication data
    auth = request.env["omniauth.auth"]
    provider = params['provider']
    identifier = auth.uid

    # try to sync user data from user database
    # if sync fails
    #   - use cached user_data if it exists
    #   - otherwise fail login
    user_data = Riyosha.find(identifier)
    if user_data
      user = User.create_or_update_with_user_data(provider, user_data)
      session[:user_id] = user.id
    else
      user = User.find_by_provider_and_identifier(provider, identifier)
      if user
        session[:user_id] = user.id
        logger.warn "Could not get user data from Riyosha. Using cached data for user with identifier #{identifier}."
      else
        logger.error "Could not get user data from Riyosha and could therefore not create new user. Login failed."
        redirect_to params[:url] || root_path, :alert => 'Login failed. We apologize for the inconvenience. Please try again later.' and return
      end
    end

    # Make CanCan re-initialize abilities based on new user id
    @current_ability = nil

    # Save session search history
    current_user.searches << searches_from_history
    current_user.save

    # Set shunting cookies
    cookies.permanent[:shunt] = cookies.permanent[:shunt_hint] = user.user_data["authenticator"] unless current_user.walk_in?

    # redirect user to the requested url
    session_return_url = session.delete(:return_url)
    redirect_to params[:url] || session_return_url || root_path, :notice => 'You are now logged in'
  end

  def destroy
    destroy_session
    redirect_to logout_url, :notice => 'You are now logged out', :only_path => false
  end

  def logout_login_as_dtu
    destroy_session
    redirect_to logout_login_as_dtu_url
  end

  def logout_login_as_dtu_url
    service ={:service => new_user_session_url({:url => params[:url], :only_dtu => true})}
    "#{Rails.application.config.auth[:cas_url]}/logout?#{service.to_query}"
  end

  def omniauth_path(provider, options = {})
    "/auth/#{provider.to_s}"
  end

  def logout_url
    if Rails.application.config.auth[:stub]
      root_url
    else
      service = { :service => root_url }
      "#{Rails.application.config.auth[:cas_url]}/logout?#{service.to_query}"
    end
  end

  def switch
    unless can? :switch, User
      render(:file => 'public/401', :format => :html, :status => :unauthorized) and return
    end

    @found_users = User.search(params[:user_q]).where('identifier <> ?', current_user.identifier).page(params[:page] || 1).per(10)
  end


  def update
    if can? :switch, User
      current_user_id = current_user.id

      # Determine the user we want to impersonate
      if params[:anonymous]
        session[:user_id] = nil
        session[:impersonate_anonymous] = true
        logger.info "User #{current_user.id}(#{current_user.name}) impersonates anonymous user"
      elsif params[:student]
        session[:user_id] = current_user.id
        session[:impersonate_student] = true
        logger.info "User #{current_user.id}(#{current_user.name}) impersonates self as student user"
      elsif params[:employee]
        session[:user_id] = current_user.id
        session[:impersonate_employee] = true
        logger.info "User #{current_user.id}(#{current_user.name}) impersonates self as employee user"
      elsif params[:identifier]
        # new_user_id is made available for switch user form to be able
        # to populate the form with submitted data when there is an error
        new_user_id = params[:identifier]
        new_user = User.find_by_identifier(new_user_id)

        if new_user == nil
          logger.info "User not found with identifier: #{new_user_id}"
          flash[:error] = 'User not found'
          redirect_to switch_user_path
          return
        end
        logger.info "User #{current_user.id}(#{current_user}) impersonates #{new_user.id}(#{new_user})"
        session[:user_id] = new_user.id
      end

      if params[:walk_in]
        logger.info "#{current_user.id}(#{current_user.name}) impersonates walk_in status"
        session[:impersonate_walk_in] = true
      end

      # Ensure that abilities are reloaded on next request
      @current_ability = nil

      flash[:notice] = "You succesfully switched user."
      flash.keep :notice

      # Store impersonating user id, so that we can switch back
      session[:original_user_id] = current_user_id

    elsif can? :switch_back, User
      logger.info "#{session[:original_user_id]} no longer impersonates"

      # Restore original user and his cancan abilities
      session[:user_id] = session[:original_user_id]
      session.delete :impersonate_anonymous
      session.delete :impersonate_student
      session.delete :impersonate_employee
      session.delete :impersonate_walk_in
      session.delete :original_user_id
      @current_ability = nil

      flash[:notice] = "You succesfully switched back."
      flash.keep :notice

    else
      flash[:error] = 'Not allowed'
    end

    redirect_to root_path
  end

  private

  def destroy_session
    order = session[:order]
    reset_session
    # Keep order in session and let orders_controller decide what to do with it
    session[:order] = order if order

    cookies.delete :shunt
  end

end
