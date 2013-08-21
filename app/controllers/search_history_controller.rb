class SearchHistoryController < ApplicationController
  before_filter :require_search_history_ability

  def index
    @searches = current_user.searches.order("created_at DESC")
  end

  def save
    @search = Search.find_by_id(params[:id])    
    @search.saved = true
    @search.save
    respond_to do |format|   
      format.js { head :no_content, status: 200 }
      format.html { redirect_to :back }
    end
  end

  def forget
    @search = Search.find_by_id(params[:id])
    @search.saved = false
    @search.save
    respond_to do |format|   
      format.js { head :no_content, status: 200 }
      format.html { redirect_to :back }
    end
  end

  def alert    
    alerted = true
    Search.transaction do
      search = Search.find_by_id(params[:id])
      search.alerted = true    
      if !search.save
        alerted = false
        flash[:error] = t('toshokan.search_history.error')
        Rails.logger.error "Couldn't save and alert search with id #{params[:id]}"
      else
        alert = Alert.new({:alert_type => "search", :query => search.query_params, :reference => search.id}, current_user)
        if !alert.save
          alerted = false
          flash[:error] = t('toshokan.search_history.error')
          Rails.logger.error "Could not update alert for search with id #{params[:id]}"
          raise ActiveRecord::Rollback
        end
      end
    end  
    respond_to do |format|   
      if alerted           
        format.js { head :no_content, status: 200 }        
      else
        format.json { render json: t('toshokan.search_history.error'), status: :internal_server_error }
      end
      format.html { redirect_to :back }
    end    
  end  

  def forget_alert
    alert_deleted = true
    Search.transaction do
      search = Search.find_by_id(params[:id])
      search.alerted = false      
      if !search.save
        alert_deleted = false
        flash[:error] = t('toshokan.search_history.error')
        Rails.logger.error "Couldn't save search with id #{params[:id]}"
      else
        alert = Alert.find(current_user, {:reference => search.id})        
        if alert.nil? || !Alert.destroy(alert.id)
          alert_deleted = false
          flash[:error] = t('toshokan.search_history.error')
          Rails.logger.error "Could not delete search alert"
          raise ActiveRecord::Rollback
        end
      end    
    end
    respond_to do |format|
      if alert_deleted
        format.js { head :no_content, status: 200 }
      else
        format.json { render json: t('toshokan.search_history.error'), status: :internal_server_error }
      end
      format.html { redirect_to :back }
    end
  end

  def destroy
    destroyed = true
    Search.transaction do
      # remove user id from search
      search = Search.find_by_id(params[:id])
      alerted = search.alerted
      search.user_id = nil
      search.alerted = false
      search.saved = false
      if !search.save
        destroyed = false
        flash[:error] = t('toshokan.search_history.error')
        Rails.logger.error "Couldn't delete user from search with id #{params[:id]}"
      else
        if alerted
          alert = Alert.find(current_user, {:reference => search.id})        
          if alert.nil? || !Alert.destroy(alert.id)
            destroyed = false
            flash[:error] = t('toshokan.search_history.error')
            Rails.logger.error "Could not delete search alert"
            raise ActiveRecord::Rollback
          end
        end
      end
    end    
    respond_to do |format|   
      if destroyed           
        format.js { head :no_content, status: 200 }        
      else
        format.json { render json: t('toshokan.search_history.error'), status: :internal_server_error }
      end
      format.html { redirect_to :back }
    end    
  end

  private

  def require_search_history_ability
    not_found unless can? :view, :search_history
  end

end
