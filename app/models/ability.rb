class Ability
  include CanCan::Ability

  def initialize(user)
    # Apply abilities based on whether user is logged in or not
    if user.authenticated?
      can :logout, User
      can :view, :search_history
      can :tag, [Bookmark, Search]
      can :alert, [:journal, Search]
    else
      if Rails.application.config.auth[:anonymous_only]
        cannot :login, User
      else
        can :login, User
      end
      can :search, :public
    end

    # Apply abilities based on which authentication provider the user used for login
    case
    when user.dtu?
      # Logged in using DTU CAS
      can :search, :dtu
      can :view, :cant_find_forms if user.employee? || user.student?
      can :view, :my_publications if user.employee?
    when user.public?
      # Logged in from outside DTU Campus
      can :search, :public
    end

    # Apply abilities based on user roles
    unless user.roles.empty?
      if user.roles.include? Role.find_by_code('DAT')
        can :view_format, ['standard', 'librarian']
      else
        can :view_format, 'standard'
      end

      can :update, User if user.roles.include? Role.find_by_code('ADM')
      can :switch, User if user.roles.include?(Role.find_by_code('SUP')) && !user.impersonating?
    end

    # User can switch back if he is impersonating another user
    if user.impersonating?
      can :switch_back, User
      cannot :login, User
      cannot :logout, User
    end


    # Apply abilities for users on walk-in PC's
    if user.walk_in?
      cannot :search, :public
      can :search, :dtu
      can :ask, :librarian
    end

    can :order, :article if user.orders_enabled?

    cannot :use_feature, :cant_find_facet
  end

end
