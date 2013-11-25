class AlertsController < ApplicationController
  before_filter :require_alert_ability

  def index    
    @alerts = Alert.all(current_user, "journal")      
    if @alerts.nil?
      @alerts = []      
      flash[:error] = t('toshokan.alerts.error')
      Rails.logger.error "Could not fetch alerts"
    end
  end

  def show    
    @alert = Alert.lookup(params[:id])
    if @alert.nil?      
      flash[:error] = t('toshokan.alerts.error')
      Rails.logger.error "Could not fetch alert"
    end
  end

  def create
    @alert = Alert.new(params[:alert], current_user)    
    
    respond_to do |format|   
      if !@alert.save
        flash[:error] = t('toshokan.alerts.error')
        Rails.logger.error "Alert #{alert.inspect} could not be saved"
        format.json { render json: t('toshokan.alerts.error'), status: :internal_server_error }
      else
        format.json { render json: @alert, status: 200 }
      end
      format.html { redirect_to :back }
    end
  end

  def destroy
    respond_to do |format|   
      if !Alert.destroy(params[:id])    
        flash[:error] = t('toshokan.alerts.error')
        format.json { render json: t('toshokan.alerts.error'), status: :internal_server_error }
        Rails.logger.error "Could not delete alert"
      else
        format.js { head :no_content, status: 200 }
      end
      format.html { redirect_to :back }
    end
  end

  private

  def require_alert_ability
    require_authentication unless can? :alert, :journal
  end

end
