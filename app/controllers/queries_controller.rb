class QueriesController < ApplicationController
  before_action :require_ability

  def require_ability
    not_found unless can? :manage, Query
  end

  def index
    @queries = Query.all.order('name asc')
    @counts  = QueryResultDocument.where(rejected: false).group('query_id').count
  end

  def show
    @query = Query.find(params[:id])
    @docs  = QueryResultDocument.where(query: @query, rejected: false)
  end

  def new
    @query = Query.new
  end

  def create
    @query = Query.create(query_params)
    if @query.valid?
      flash[:notice] = 'The query was created'
      redirect_to queries_index_path
    else
      flash[:error] = 'Error while submitting form'
      render 'new'
    end
  end

  def destroy
    q = Query.find(params[:id]) || not_found
    q.destroy
    flash[:notice] = "The query '#{q.name}' was removed"
    redirect_to queries_index_path
  end

  def update
    q = Query.find(params[:id]) || not_found
    if params.has_key? :enabled
      q.enabled = params[:enabled]
      q.save
      flash[:notice] = "The query '#{q.name}' was #{q.enabled ? 'enabled' : 'disabled'}"
    else
      [:name, :query_string, :filter].each do |f|
        q.send("#{f}=", params[:query][f]) if params[:query].has_key? f
      end
      q.save
      flash[:notice] = "The query '#{q.name}' was updated"
    end
    redirect_to queries_index_path
  end

  def edit
    @query = Query.find(params[:id]) || not_found
  end

  def try_query
    @query = Query.find(params[:id]) || not_found
    redirect_to catalog_index_path(q: "#{@query.to_solr_query} AND NOT source_ss:orbit")
  end

  def reject
    @query_result_document = QueryResultDocument.find(params[:doc_id]) || not_found
    if @query_result_document.update_attributes!(document: nil, duplicate: nil, rejected: true)
      render 'remove_rejected', status: 200 and return if request.xhr?
      flash[:notice] = 'Added result document to ignore list'
    else
      head 400 and return if request.xhr?
      flash[:error] = 'Error when updating document'
    end
    redirect_to show_query_path(@query_result_document.query)
  end

  private

  def query_params
    params.require(:query).permit(:name, :query_string, :filter)
  end
end
