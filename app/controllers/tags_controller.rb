class TagsController < ApplicationController
  before_filter :require_tag_ability

  # Tag management actions

  def manage
    @tags = current_user.tags.all(:order => 'name')
  end

  # Document tagging actions

  def index
    @document = Hashie::Mash.new({:id => params[:document_id]})
    @bookmark = current_user.bookmarks.find_or_create_by_document_id(@document.id)
    @tags = current_user.tags.all(:order => 'name')
    @return_url = request.url
    if params && params[:return_url]
      @return_url = params[:return_url]
    end
  end

  def new
  end

  def create
    @document = Hashie::Mash.new({:id => params[:document_id]})
    current_user.tag(@document, params[:tag_name])

    redirect_to only_path(params[:return_url]) unless request.xhr?
    render :partial => 'tags/tag_refresh' and return if request.xhr?
  end


  # Tag management and document tagging actions

  def destroy
    tag = current_user.tags.find_by_id(params[:id])
    not_found unless tag

    if (params[:document_id])
      @document = Hashie::Mash.new({:id => params[:document_id]})
      bookmark = current_user.bookmarks.find_by_document_id(@document.id)
      bookmark.tags.delete(tag) if bookmark
    else
      tag.delete
    end

    redirect_to only_path(params[:return_url]) unless request.xhr?
    render :partial => 'tags/tag_refresh' and return if request.xhr?
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
    not_found unless can? :tag, Bookmark
  end

end
