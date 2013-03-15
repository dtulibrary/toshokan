class FeedbackController < ApplicationController
  def show 
    if params[:message] && params[:name] && params[:email]
      # Parameters are present meaning a form submission

      if params[:message].blank? || params[:email].blank?
        # Inform user of missing required fields
        @errors = []
        @errors << 'message' if params[:message].blank?
        @errors << 'email' if params[:email].blank?
        render 'error'
      else 
        # Send mail and show completion to user 

        # Remove any newlines since these values will go into SMTP protocol and
        # mail header. Also remove < and > from name since it would probably break email address
        name = params[:name].gsub /\n|<.*?>/, ''
        email = params[:email].gsub /\n/, ''
        email = name.blank? ? email : "#{name} <#{email}>"

        to = Rails.application.config.action_mailer.smtp_settings[:to]

        FeedbackMailer.feedback_email(current_user,
          :message => params[:message], 
          :name => name, 
          :from => email,
          :to => to
        ).deliver if to

        render 'complete'
      end
    else
      # Show form without layout for XHR requests
      render 'show', :layout => nil and return if request.xhr?
    end
  end
end
