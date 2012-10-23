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

    # Abilities that are specific to application mode
    # XXX: These are all just imaginary examples of configurations
    case Rails.application.config.application_mode
    when :dtu
      # Must log in when in DTU mode
      if user.anonymous?
        can :login_cas, User
      else
        can :logout_cas, User
        can :tag, SolrDocument
      end

    when :dtu_kiosk
      # As an example the kiosk mode allows both anonymous users and logins
      # The real deal would probably only allow anonymous users with credentials-on-demand
      can :be_anonymous, User
      if user.anonymous?
        can :login_cas, User
      else
        can :logout_cas, User
        can :tag, SolrDocument
      end

=begin
    when :i4i
      # Information For Innovation
      can :be_anonymous, User
      if user.anonymous?
        can :login_velo, User
      else
        can :tag, SolrDocument
        can :logout_velo, User
      end
=end

    end

    # Abilities that work regardless of application mode
    if user.anonymous?
    else 
      can :logout, User
      can :switch, User if user.roles.include?(Role.find_by_code('SUP')) && !user.impersonating?
      can :switch_back, User if user.impersonating?
      can :manage, User if user.roles.include? Role.find_by_code('ADM')
    end
  end

end
