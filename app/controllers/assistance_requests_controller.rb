class AssistanceRequestsController < ApplicationController
  
  def index
    if can? :request, :assistance
      if can? :view, :all_assistance_requests
        @assistance_requests = AssistanceRequest.all
      elsif can? :view, :own_assistance_requests
        @assistance_requests = AssistanceRequest.find_by_user_id current_user.id
      else
        head :not_found
      end
    else
      head :not_found
    end
  end

  def new
    if can? :request, :assistance
      @genre = genre_from params
      
      if @genre
        @assistance_request = assistance_request_from(params) || assistance_request_for(@genre)
        
        if @assistance_request
          flash.now[:alert] = %q{
            Requesting a librarian's assistance will invoke <b>manual procedures</b>. 
            Please review your request before sending it.}.html_safe
        else
          head :bad_argument 
        end
      else
        head :bad_request
      end
    else
      render 'need_to_login'
    end
  end

  def create
    if can? :request, :assistance
      genre = genre_from params
      
      if genre
        assistance_request = assistance_request_from params

        if assistance_request
          assistance_request.user = current_user
          assistance_request.email = current_user.email

          action = params[:button] || :create

          unless can? :select, :pickup_location
            assistance_request.physical_location = current_user.address
          end

          case action.to_sym
          when :confirm
            if assistance_request.valid?
              assistance_request.save!
              SendIt.delay.send_request_assistance_mail genre, current_user, params[:assistance_request]
              flash[:notice] = 'Your request was sent to a librarian'
              redirect_to assistance_request_path(assistance_request)
            else
              flash[:error] = assistance_request.errors
              redirect_to new_assistance_request_path(assistance_request)
            end
          else
            @genre = genre
            @assistance_request = assistance_request
            
            unless assistance_request.valid?
              flash.now[:error] = 'One or more required fields are empty'
              params.delete :button
              render :new
            end
          end
        else
          head :bad_request
        end
      else
        head :bad_request
      end
    else
      head :not_found
    end
  end

  def show
    if can? :request, :assistance
      if AssistanceRequest.exists? params[:id]
        @assistance_request = AssistanceRequest.find params[:id]
      else
        head :not_found
      end
    else
      head :not_found
    end
  end

  def genre_from params 
    params[:genre].to_sym if params[:genre]
  end

  def assistance_request_from params
    case genre_from params
    when :journal_article
      JournalArticleAssistanceRequest.new params[:assistance_request]
    when :conference_article
      ConferenceArticleAssistanceRequest.new params[:assistance_request]
    when :book
      BookAssistanceRequest.new params[:assistance_request]
    end
  end

  def assistance_request_for genre
    case genre
    when :journal_article
      JournalArticleAssistanceRequest.new
    when :conference_article
      ConferenceArticleAssistanceRequest.new
    when :book
      BookAssistanceRequest.new
    end
  end
end
