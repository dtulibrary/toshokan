class SearchHistoryController < ApplicationController
  before_filter :require_search_history_ability, :except => :summary

  def index
    @searches = current_user.searches.order("created_at DESC")
  end

  def summary
    if(current_user.authenticated?)
      @searches = current_user.searches.order("created_at DESC")
    else
      @searches = searches_from_history
    end
  end

  def save
    @search = Search.find_by_id(params[:id])    
    @search.saved = true
    @search.save
    redirect_to :back
  end

  def forget
    @search = Search.find_by_id(params[:id])
    @search.saved = false
    @search.save
    redirect_to :back
  end

  def alert    
    Search.transaction do
      search = Search.find_by_id(params[:id])
      search.alerted = true    
      if !search.save
        flash[:error] = t('toshokan.search_history.error')
        Rails.logger.error "Couldn't save and alert search with id #{params[:id]}"
      else
        alert = Alert.new({:alert_type => "search", :query => search.query_params, :name => search.id}, current_user)
        if !alert.save
          flash[:error] = t('toshokan.search_history.error')
          Rails.logger.error "Could not update alert for search with id #{params[:id]}"
          raise ActiveRecord::Rollback
        end
      end
    end    
    redirect_to :back
  end  

  def forget_alert
    Search.transaction do
      search = Search.find_by_id(params[:id])
      search.alerted = false      
      if !search.save
        flash[:error] = t('toshokan.search_history.error')
        Rails.logger.error "Couldn't save search with id #{params[:id]}"
      else
        alert = Alert.find(current_user, search.query_params)        
        if alert.nil? || !Alert.destroy(alert.id)
          flash[:error] = t('toshokan.search_history.error')
          Rails.logger.error "Could not delete search alert"
          raise ActiveRecord::Rollback
        end
      end    
    end
    redirect_to :back
  end

  def destroy
    Search.transaction do
      # remove user id from search
      search = Search.find_by_id(params[:id])
      alerted = search.alerted
      search.user_id = nil
      search.alerted = false
      search.saved = false
      if !search.save
        flash[:error] = t('toshokan.search_history.error')
        Rails.logger.error "Couldn't delete user from search with id #{params[:id]}"
      else
        if alerted
          alert = Alert.find(current_user, search.query_params)        
          if alert.nil? || !Alert.destroy(alert.id)
            flash[:error] = t('toshokan.search_history.error')
            Rails.logger.error "Could not delete search alert"
            raise ActiveRecord::Rollback
          end
        end
      end
    end
    redirect_to :back
  end

  private

  def require_search_history_ability
    not_found unless can? :view, :search_history
  end

end
