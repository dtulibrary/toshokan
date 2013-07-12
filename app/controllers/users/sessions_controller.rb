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
  end

  def update
    if can? :switch, User
      # new_user_id is made available for switch user form to be able
      # to populate the form with submitted data when there is an error
      @new_user_id = params[:user][:identifier]
      user_data = Riyosha.find(@new_user_id)

      if user_data == nil
        flash[:error] = 'User not found'
        redirect_to switch_user_path, flash: flash
        return
      end

      new_user = User.create_or_update_with_user_data('cas', user_data)
      session[:original_user_id] = current_user.id
      session[:user_id] = new_user.id

      # Switching user affects abilities - in particular when switching
      # to a user that can also switch user, it should not be allowed
      # to switch further. Instead it should be allowed to switch back.
      # Otherwise we would need to keep a stack of the users, that was
      # switched into in order to get the proper "switch back" functionality
      # and that behaviour just seems silly.
      @current_ability = nil
      flash[:notice] = "You succesfully switched user."
      flash.keep :notice

    elsif can? :switch_back, User
      # Restore original user and his cancan abilities
      session[:user_id] = session[:original_user_id]
      session.delete :original_user_id

      @current_ability = nil
      flash[:notice] = "You succesfully switched user."
      flash.keep :notice

    else
      flash[:error] = 'Not allowed'
    end

    redirect_to root_path
  end


end
