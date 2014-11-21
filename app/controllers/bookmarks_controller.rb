class BookmarksController < CatalogController
  def update
    _, @document = get_solr_response_for_doc_id(params[:document_id], add_access_filter)
    current_or_guest_user.existing_bookmark_for(@document) || current_user.bookmarks.create({document:@document})

    respond_to do | format |
      format.js   { render :partial => 'tags/tag_refresh' }
      format.html { redirect_to only_path(params[:return_url]) }
    end
  end

  def destroy
    _, @document = get_solr_response_for_doc_id(params[:document_id], add_access_filter)
    bookmark = current_user.existing_bookmark_for(@document)
    current_or_guest_user.bookmarks.delete(bookmark) if bookmark

    respond_to do | format |
      format.js   { render :partial => 'tags/tag_refresh' }
      format.html { redirect_to only_path(params[:return_url]) }
    end
  end

end
