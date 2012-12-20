class BookmarksController < CatalogController
  def update
    @document = Hashie::Mash.new({:id => params[:id]})
    success = current_or_guest_user.existing_bookmark_for(@document.id) || current_user.bookmarks.create({:document_id => @document.id})

    redirect_to params[:return_url], :only_path => true unless request.xhr?
    render :partial => 'tags/tag_refresh' and return if request.xhr?
  end

  def destroy
    @document = Hashie::Mash.new({:id => params[:id]})
    bookmark = current_user.existing_bookmark_for(@document.id)
    success = (!bookmark) || current_or_guest_user.bookmarks.delete(bookmark)

    redirect_to params[:return_url], :only_path => true unless request.xhr?
    render :partial => 'tags/tag_refresh' and return if request.xhr?
  end


end