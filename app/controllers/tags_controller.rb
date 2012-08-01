class TagsController < ApplicationController

  def new
  end

  def create
    @document = SolrDocumentPointer.find_or_create_by_solr_id(params[:document_id])
    current_user.tag(@document, with: @document.tags_from(current_user) + [params[:tag_name]], :on => :tags)
    redirect_to params[:return_url]
  end

  def destroy
    @document = SolrDocumentPointer.find_or_create_by_solr_id(params[:document_id])
    tag = ActsAsTaggableOn::Tag.find(params[:id])
    current_user.tag(@document, with: @document.tags_from(current_user) - [tag.name], :on => :tags)
    redirect_to params[:return_url]
  end

  def index
    @tags = current_user.owned_tags
  end

  def show
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
    @taggings = current_user.owned_taggings.where(tag_id: params[:id])
  end

end
