class BookmarksController < ApplicationController
  include Toshokan::PerformsSearches
  include Toshokan::Catalog

  before_filter :require_tag_ability

  def update
    _, @document = get_solr_response_for_doc_id(params[:id], add_access_filter)
    current_or_guest_user.existing_bookmark_for(@document) || current_user.bookmarks.create(document: @document)

    respond_to do | format |
      format.js   { render :partial => 'tags/tag_refresh' }
      format.html { redirect_to only_path(params[:return_url]) }
    end
  end

  def destroy
    _, @document = get_solr_response_for_doc_id(params[:id], add_access_filter)
    bookmark = current_user.existing_bookmark_for(@document)
    not_found unless bookmark
    current_or_guest_user.bookmarks.delete(bookmark) if bookmark

    respond_to do | format |
      format.js   { render :partial => 'tags/tag_refresh' }
      format.html { redirect_to only_path(params[:return_url]) }
    end
  end

  private

  def require_tag_ability
    require_authentication unless can? :tag, Bookmark
  end


end
