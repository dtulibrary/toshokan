class TagsController < ApplicationController
  layout 'with_search_bar'

  include Toshokan::PerformsSearches
  include Toshokan::Catalog

  before_filter :require_tag_ability

  # Tag management actions

  def manage
    @tags = current_user.tags.all.order :name
  end

  # Document tagging actions

  def index
    _, @document = get_solr_response_for_doc_id(params[:document_id], search_builder.add_access_filter)
    @bookmark = current_user.bookmarks.find_by_document_id(@document.id)
    @tags = current_user.tags(:order => 'name')
    @return_url = request.url
    if params && params[:return_url]
      @return_url = params[:return_url]
    end
    respond_to do | format |
      format.js   { render :partial => 'tags/tag_refresh' }
      format.html { render }
    end
  end

  def new
  end

  def create
    @document = SolrDocument.new(SolrDocument.unique_key => params[:document_id])
    current_user.tag(@document, params[:tag_name])

    respond_to do | format |
      format.js   { render :partial => 'tags/tag_refresh' }
      format.html { redirect_to only_path(params[:return_url]) }
    end
  end

  # Tag management and document tagging actions

  def destroy
    tag = current_user.tags.find_by_id(params[:id])
    not_found unless tag

    if (params[:document_id])
      @document = SolrDocument.new(SolrDocument.unique_key =>  params[:document_id])
      bookmark = current_user.existing_bookmark_for(@document)
      bookmark.tags.delete(tag) if bookmark
    else
      tag.delete
    end

    respond_to do | format |
      format.js   { render :partial => 'tags/tag_refresh' }
      format.html { redirect_to only_path(params[:return_url]) }
    end
  end

  def edit
    @tag = current_user.tags.find_by_id params[:id]
    not_found unless @tag
  end

  def update
    tag = current_user.tags.find_by_id params[:id]
    new_tag_name = params[:tag_name]
    not_found unless tag and new_tag_name

    unless params[:cancel]
      tag.name = new_tag_name
      tag.save
    end

    redirect_to manage_tags_path
  end

  private

  def require_tag_ability
    require_authentication unless can? :tag, Bookmark
  end

  def search_action_url
    catalog_index_url
  end

end
