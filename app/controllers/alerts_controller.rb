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

    if !@alert.save
      flash[:error] = t('toshokan.alerts.error')
      Rails.logger.error "Alert #{alert.inspect} could not be saved"
    end
    redirect_to :back
  end

  def destroy
    
    if !Alert.destroy(params[:id])    
      flash[:error] = t('toshokan.alerts.error')
      Rails.logger.error "Could not delete alert"
    end
    redirect_to :back
  end

  private

  def require_alert_ability
    not_found unless can? :alert, :journal
  end

end
