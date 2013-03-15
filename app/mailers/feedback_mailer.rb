class FeedbackMailer < ActionMailer::Base

  def feedback_email user, mail_opts = {}
    if user.walk_in?
      # Walk-in
      @user_info = 'Walk-in user'
      subject_sub = 'walk-in user'
    elsif user.authenticated?
      # Logged in - send info about user (username, provider, ... )
      @user_info = "Authenticated user - username: #{user.username}, identifier: #{user.identifier} (from #{user.provider})"
      subject_sub = 'authenticated user'
    else
      # Public, not logged in
      @user_info = 'Public user - not logged in'
      subject_sub = 'public user'
    end
    @message = mail_opts[:message]
    @name = mail_opts[:name]
    @sender = mail_opts[:from]
    mail :to => mail_opts[:to], :subject => "[DTU Library] Feedback from #{subject_sub}", :from => @sender || 'no-reply@dtic.dtu.dk'  
  end

end
