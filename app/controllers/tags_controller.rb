class TagsController < ApplicationController

  # Tag management actions

  def index
    @tags = current_user.owned_tags.all(:order => 'name')
  end

  # Document tagging actions

  def new
  end

  def create
    document = SolrDocumentPointer.find_or_create_by_solr_id(params[:document_id])
    add_tag(current_user, document, params[:tag_name])
    redirect_to params[:return_url], :only_path => true
  end


  # Tag management and document tagging actions

  def destroy
    tag = ActsAsTaggableOn::Tag.find(params[:id])
    if (params[:document_id])
      document = SolrDocumentPointer.find_or_create_by_solr_id(params[:document_id])
      remove_tag(current_user, document, tag.name)
    else
      pointer_ids = taggings_for_id(params[:id]).map(&:taggable_id)
      pointer_ids.each do |pointer_id|
        document = SolrDocumentPointer.find(pointer_id)
        remove_tag(current_user, document, tag.name)
      end
    end
    redirect_to params[:return_url], :only_path => true
  end

  def edit
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
  end

  def update
    tag = ActsAsTaggableOn::Tag.find(params[:id])
    new_tag_name = params[:tag_name]

    taggings_for_id(tag.id).map(&:taggable_id).each do |pointer_id|
        document = SolrDocumentPointer.find(pointer_id)
        remove_tag(current_user, document, tag.name)
        add_tag(current_user, document, new_tag_name)
    end

    redirect_to tags_path
  end

  def add_tag(user, document, tag_name) 
    user.tag(document, with: document.tags_from(user) + [tag_name], :on => :tags)
  end

  def remove_tag(user, document, tag_name) 
    user.tag(document, with: document.tags_from(user) - [tag_name], :on => :tags)
  end

  def taggings_for_id(id)
    current_user.owned_taggings.where(tag_id: id)
  end

end
