class TagsController < CatalogController
  before_filter :require_tag_ability

  # don't execute filters from catalog controller to avoid
  # messing up the search stored in session
  skip_before_filter :search_session
  skip_before_filter :history_session
  skip_before_filter :delete_or_assign_search_session_params
  skip_after_filter  :set_additional_search_session_values

  # Tag management actions

  def manage
    @tags = current_user.tags.all.order :name
  end

  # Document tagging actions

  def index
    _, @document = get_solr_response_for_doc_id(params[:document_id], add_access_filter)
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
    _, @document = get_solr_response_for_doc_id(params[:document_id], add_access_filter)
    current_user.tag(@document, params[:tag_name])

    respond_to do | format |
      format.js   { render :partial => 'tags/tag_refresh' }
      format.html { redirect_to only_path(params[:return_url])}
    end
  end


  # Tag management and document tagging actions

  def destroy
    tag = current_user.tags.find_by_id(params[:id])
    not_found unless tag

    if (params[:document_id])
      _, @document = get_solr_response_for_doc_id(params[:document_id], add_access_filter)
      bookmark = current_user.bookmarks.find_by_document_id(@document.id)
      bookmark.tags.delete(tag) if bookmark
    else
      tag.delete
    end

    respond_to do | format |
      format.js   { render :partial => 'tags/tag_refresh' }
      format.html { redirect_to only_path(params[:return_url])}
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
