class FeedbacksController < ApplicationController
  def new
    # prepopulate name and email
    @name    = params[:name]  || (current_user.name if current_user.name != current_user.email)
    @email   = params[:email] || current_user.email
    @message = params[:message]
    (render 'new_modal', :layout => nil && return) if request.xhr?
  end

  def create
    (render_error && return) if params[:message].blank? || params[:email].blank?

    # Send mail and show completion to user

    # Remove any newlines since these values will go into SMTP protocol and
    # mail header. Also remove < and > from name since it would probably break email address
    name = params[:name].gsub(/\n|<.*?>/, '')
    email = params[:email].gsub(/\n/, '')
    email = name.blank? ? email : "#{name} <#{email}>"

    SendIt.send_feedback_email(current_user,
                               :message => params[:message],
                               :from    => email)
    render 'complete'
  end

  private

  def render_error
    # Inform user of missing required fields
    @errors = []
    @errors << 'message' if params[:message].blank?
    @errors << 'email' if params[:email].blank?
    render 'error'
  end
end
