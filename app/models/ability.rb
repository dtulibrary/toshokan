class Ability
  include CanCan::Ability

  def initialize(user)
    # Apply abilities based on whether user is logged in or not
    if user.authenticated?
      can :logout, User
      can :view, :search_history
    else
      if Rails.application.config.anonymous_only?
        cannot :login, User
      else
        can :login, User
      end
      can :search, :public
      can :remember, :auth_provider
    end

    # Apply abilities based on which authentication provider the user used for login
    case user.provider
    when 'dtu_cas'
      # Logged in using DTU CAS
      can :tag, [Bookmark, Search]
      can :share, Tag
      can :search, :dtu
    when 'public'
      # Logged in from outside DTU Campus
      can :tag, [Bookmark, Search]
      can :share, Tag
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
    can :switch_back, User if user.impersonating?

    # Apply abilities for users on walk-in PC's
    if user.walk_in?
      cannot :login, User
      cannot :search, :public
      can :search, :dtu
    end
  end

end
