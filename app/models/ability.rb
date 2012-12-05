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
      if user.anonymous?
        can :login_cas, User
      else
        can :logout_cas, User
        can :tag, SolrDocument
      end
    when :dtu_kiosk
      if user.anonymous?
        can :be_anonymous, User
        can :login_cas, User
      else
        can :logout_cas, User
        can :tag, SolrDocument
      end
    when :i4i
      if user.anonymous?
        can :be_anonymous, User
        can :login_velo, User
      else
        can :logout_velo, User
        can :tag, SolrDocument
      end
    end

    # Abilities that work regardless of application mode
    unless user.anonymous?
      can :logout, User

      if user.roles.include? Role.find_by_code('DAT')
        can :view_format, ['compact', 'standard', 'librarian']
      else
        can :view_format, ['compact', 'standard']
      end

      can :view_raw, SolrDocument if user.roles.include? Role.find_by_code('DAT')
      can :update, User if user.roles.include? Role.find_by_code('ADM')
      can :switch, User if user.roles.include?(Role.find_by_code('SUP')) && !user.impersonating?
      can :switch_back, User if user.impersonating?
    end
  end

end
