class TagsController < ApplicationController

  def new
  end

  def create
    @document = SolrDocumentPointer.find_or_create_by_solr_id(params[:document_id])
    current_user.tag(@document, with: params[:tag_name], :on => :tags)
    redirect_to catalog_index_path
  end

  def index
    @tags = current_user.owned_tags
  end

  def show
    pointer_ids = current_user.owned_taggings.where(tag_id: params[:id]).map(&:taggable_id)
    @solr_ids = SolrDocumentPointer.find(pointer_ids).map(&:solr_id)
  end

end
