class BookmarksController < CatalogController
  def update
    @document = Hashie::Mash.new({:id => params[:id]})
    current_or_guest_user.existing_bookmark_for(@document.id) || current_user.bookmarks.create({:document_id => @document.id})

    redirect_to only_path(params[:return_url]) unless request.xhr?
    render :partial => 'tags/tag_refresh' and return if request.xhr?
  end

  def destroy
    @document = Hashie::Mash.new({:id => params[:id]})
    bookmark = current_user.existing_bookmark_for(@document.id)
    current_or_guest_user.bookmarks.delete(bookmark) if bookmark

    redirect_to only_path(params[:return_url]) unless request.xhr?
    render :partial => 'tags/tag_refresh' and return if request.xhr?
  end


end
