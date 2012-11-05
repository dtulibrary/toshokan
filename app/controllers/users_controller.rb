class UsersController < ApplicationController
  protect_from_forgery

  def index
    if can? :update, User
      @all_users = User.all :order => 'firstname asc, lastname asc'
      @all_roles = Role.all :order => :name
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
          target_user.roles = Role.all.collect { |role| role if params.has_key? role.id.to_s }.compact
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
