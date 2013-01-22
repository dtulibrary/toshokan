class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    # Create guest user if necessary
    user ||= User.new

    # Apply abilities based on whether user is logged in or not
    if user.anonymous?
      can :login, User
    else
      can :logout, User
    end

    # Apply abilities based on user roles
    unless user.roles.empty?
      if user.roles.include? Role.find_by_code('DAT')
        can :view_format, ['standard', 'librarian']
      else
        can :view_format, 'standard'
      end

      can :view_raw, SolrDocument if user.roles.include? Role.find_by_code('DAT')
      can :update, User if user.roles.include? Role.find_by_code('ADM')
      can :switch, User if user.roles.include?(Role.find_by_code('SUP')) && !user.impersonating?
    end
    
    # User can switch back if he is impersonating another user
    can :switch_back, User if user.impersonating?

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
    else
      # Not authenticated
      can :search, :public
      can :remember, :auth_provider
    end

    # Apply abilities for users on walk-in PC's
    if user.walk_in?
      cannot :login, User
      can :search, :dtu
    end
  end

end
