class Ability
  include CanCan::Ability

  def initialize(user)
    # Apply abilities based on whether user is logged in or not
    if user.authenticated?
      can :logout, User
      can :view,   :search_history
      can :tag,    [Bookmark, Search]
      can :alert,  [:journal, Search]
    else
      can :login, User
      can :search, :public
    end

    # Apply abilities based on which authentication provider the user used for login
    case
    when user.dtu?
      # Logged in using DTU CAS
      can :search,  :dtu
      can :request, :assistance      if user.employee? || user.student?
      can :view,    :my_publications if user.employee?
      can :select,  :pickup_location if user.student?
    when user.public?
      # Logged in from outside DTU Campus
      can :search,  :public
    end

    # Apply abilities based on user roles
    unless user.roles.empty?
      if user.roles.include? Role.find_by_code('DAT')
        can :view_format, ['standard', 'librarian']
      else
        can :view_format, 'standard'
      end

      can :update, User if user.roles.include? Role.find_by_code('ADM')

      if user.roles.include? Role.find_by_code('SUP')
        can :switch, User if !user.impersonating?
        can :reorder, Order
        # can :view_any, Order
        can :view, :extended_info
      end
    end

    # User can switch back if he is impersonating another user
    if user.impersonating?
      can    :switch_back, User
      cannot :login,       User
      cannot :logout,      User
    end


    # Apply abilities for users on walk-in PC's
    if user.walk_in?
      cannot :search, :public
      can    :search, :dtu
      can    :ask,    :librarian
    end

    can    :order,       :article if user.orders_enabled?
  end

end
