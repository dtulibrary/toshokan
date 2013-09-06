class Users::SessionsController < ApplicationController
  skip_before_filter :authenticate, :only => [ :setup, :create, :new ]

  def setup
    case
    when session[:only_dtu]
      request.env['omniauth.strategy'].options[:login_url] = '/login?only=dtu&template=dtu_user'
    when session[:prefer_dtu]
      request.env['omniauth.strategy'].options[:login_url] = '/login?template=dtu_user'
    else
      request.env['omniauth.strategy'].options[:login_url] = '/login'
    end

    render :text => "Omniauth setup phase.", :status => 404
  end

  def new
    unless can? :login, User
      render(:file => 'public/401', :format => :html, :status => :unauthorized) and return
    end

    session[:return_url] ||= '/'

    case
    when cookies[:shunt] == 'dtu'
      session[:only_dtu] = true
    when cookies[:shunt_hint] == 'dtu'
      session[:prefer_dtu] = true
    when current_user.campus? && !current_user.walk_in?
      session[:prefer_dtu] = true
    end

    redirect_to omniauth_path(:cas)
  end

  def create
    unless can? :login, User
      render(:file => 'public/401', :format => :html, :status => :unauthorized) and return
    end

    # extract authentication data
    auth = request.env["omniauth.auth"]
    provider = params['provider']
    identifier = auth.uid

    #  sync user data from user database
    user_data = Riyosha.find(identifier)
    user = User.create_or_update_with_user_data(provider, user_data)
    session[:user_id] = user.id

    # Make CanCan re-initialize abilities based on new user id
    @current_ability = nil

    # Save session search history
    current_user.searches << searches_from_history
    current_user.save

    # Set shunting cookie(s)
    cookies.permanent[:shunt] = cookies.permanent[:shunt_hint] = user.user_data["authenticator"] unless current_user.walk_in?

    # redirect user to the requested url
    redirect_to params[:url] || session.delete(:return_url) || root_path, :notice => 'You are now logged in'
  end

  def destroy
    order = session[:order]
    reset_session
    # Keep order in session and let orders_controller decide what to do with it
    session[:order] = order if order

    cookies.delete :shunt

    redirect_to logout_url, :notice => 'You are now logged out', :only_path => false
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

    @found_users = []
    q = params[:user_q]
    if q
      logger.debug "Query: #{q}"

      tokens = q.split
      logger.debug "Tokens: #{tokens}"

      query  = User.where('identifier <> ?', current_user.identifier)
      tokens.each do |token|
        query = query.where('LOWER(user_data) LIKE ?', "%#{token.downcase}%")
      end
      @found_users = query.order(:identifier).limit(10)
      logger.debug "Found users with identifiers: #{@found_users.map(&:identifier)}"
    end

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
          redirect_to switch_user_path, flash: flash
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


end
