class UsersController < ApplicationController
  protect_from_forgery


  def index
    if can? :update, User

      @all_users = User.search(params[:user_q] || '').includes(:roles).order('email asc')
      if params[:roles]
        params[:roles].each do |r|
          @all_users = @all_users.where(:id => User.select('users.id').joins(:roles).where(:roles => {:id => r }))
        end
      end
      @all_users = @all_users
        .page(params[:page] || 1)
        .per(params[:all] ? 100000 : 10)

      @all_roles = Role.all.order :name
    else
      deny_access and return
    end
  end

  def update
    if can? :update, User
      begin
        target_user = User.find params[:id]
        if params[:ajax]
          # This is an ajax request setting a single role
          role = Role.find params[:role]
          target_user.roles << role unless target_user.roles.include? role
          head :ok
        else
          # This is a regular form submit indicating for each role if it's set or not
          target_user.roles = Role.all.collect { |r| r if params.has_key? r.id.to_s }.compact
          redirect_to users_path
        end
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end
    else
      deny_access and return
    end
  end

  def destroy
    if can? :update, User
      begin
        target_user = User.find params[:id]
        target_user.roles.delete Role.find(params[:role])
        head :ok
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end
    else
      deny_access and return
    end
  end
end
