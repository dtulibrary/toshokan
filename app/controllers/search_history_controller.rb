class SearchHistoryController < ApplicationController
  layout 'with_search_bar'

  include Blacklight::SearchContext
  include Toshokan::BuildsToc

  before_filter :require_search_history_ability

  def initialize
    Search.paginates_per 10
    super
  end

  def index
    @searches = current_user.searches.order("updated_at DESC").page params[:page]
    paginate
  end

  def saved
    @searches = current_user.searches.where(saved: true).order("created_at DESC").page params[:page]
    paginate
    render 'search_history/index'
  end

  def alerted
    @searches = current_user.searches.where(alerted: true).order("created_at DESC").page params[:page]
    paginate
    render 'search_history/index'
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
    success = true
    search = Search.find_by_id(params[:id])
    search.alerted = true

    Search.transaction do
      if search.save!
        alert = Alert.new({:alert_type => "search", :query => search.query_params, :reference => search.id}, current_user)
        success = alert.save
        unless success
          flash[:error] = t('toshokan.search_history.error')
          Rails.logger.error "Could not update alert for search with id #{params[:id]}"
          raise ActiveRecord::Rollback
        end
      else
        success = false
        flash[:error] = t('toshokan.search_history.error')
        Rails.logger.error "Couldn't save and alert search with id #{params[:id]}"
      end
    end

    respond_to do |format|
      if success
        format.js { head :no_content, status: 200 }
      else
        format.json { render json: t('toshokan.search_history.error'), status: :internal_server_error }
      end
      format.html { redirect_to :back }
    end
  end

  def forget_alert
    success = true
    search = Search.find_by_id(params[:id])
    search.alerted = false

    Search.transaction do
      if search.save
        alert = Alert.find(current_user, {:reference => search.id})
        if alert.nil? || !Alert.destroy(alert.id)
          success = false
          flash[:error] = t('toshokan.search_history.error')
          Rails.logger.error "Could not delete search alert"
          raise ActiveRecord::Rollback
        end
      else
        success = false
        flash[:error] = t('toshokan.search_history.error')
        Rails.logger.error "Couldn't save search with id #{params[:id]}"
      end
    end

    respond_to do |format|
      if success
        format.js { head :no_content, status: 200 }
      else
        format.json { render json: t('toshokan.search_history.error'), status: :internal_server_error }
      end
      format.html { redirect_to :back }
    end
  end

  def destroy
    success = true
    # remove user id from search
    search = Search.find_by_id(params[:id])
    alerted = search.alerted
    search.user_id = nil
    search.alerted = false
    search.saved = false

    Search.transaction do
      if search.save
        if alerted
          alert = Alert.find(current_user, {:reference => search.id})
          if alert.nil? || !Alert.destroy(alert.id)
            success = false
            flash[:error] = t('toshokan.search_history.error')
            Rails.logger.error "Could not delete search alert"
            raise ActiveRecord::Rollback
          end
        end
      else
        success = false
        flash[:error] = t('toshokan.search_history.error')
        Rails.logger.error "Couldn't delete user from search with id #{params[:id]}"
      end
    end

    respond_to do |format|
      if success
        format.js { head :no_content, status: 200 }
      else
        format.json { render json: t('toshokan.search_history.error'), status: :internal_server_error }
      end
      format.html { redirect_to :back }
    end
  end

  private

  def require_search_history_ability
    require_authentication unless can? :view, :search_history
  end

  # define/alias methods so that pagination (on a Solr result) on search page can be reused
  def paginate
    @response = @searches

    class <<@response
      alias :rows :length
      alias :total :total_count

      def docs
        self
      end

      def start
        (current_page - 1) * length
      end
    end
  end
end
