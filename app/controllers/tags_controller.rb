class TagsController < ApplicationController

  # Tag management actions

  def index
    if can? :tag, SolrDocument
      @tags = current_user.owned_tags.all(:order => 'name')
    else 
      not_found
    end
  end

  # Document tagging actions

  def new
    not_found unless can? :tag, SolrDocument
  end

  def create
    if can? :tag, SolrDocument
      document = SolrDocumentPointer.find_or_create_by_solr_id(params[:document_id])
      add_tag(current_user, document, params[:tag_name])
      redirect_to params[:return_url], :only_path => true
    else
      not_found
    end
  end


  # Tag management and document tagging actions

  def destroy
    if can? :tag, SolrDocument
      if ActsAsTaggableOn::Tag.exists? :id => params[:id]
        tag = ActsAsTaggableOn::Tag.find(params[:id])
        if (params[:document_id])
          document = SolrDocumentPointer.find_or_create_by_solr_id(params[:document_id])
          remove_tag(current_user, document, tag.name)
        else
          pointer_ids = taggings_for_id(params[:id]).map(&:taggable_id)
          if pointer_ids.size > 0
            pointer_ids.each do |pointer_id|
              document = SolrDocumentPointer.find(pointer_id)
              remove_tag(current_user, document, tag.name)
            end
          else
            not_found
          end
        end
        redirect_to params[:return_url], :only_path => true
      else
        not_found
      end
    else
      not_found
    end
  end

  def edit
    if can? :tag, SolrDocument
      if ActsAsTaggableOn::Tag.exists? :id => params[:id]
        @tag = ActsAsTaggableOn::Tag.find(params[:id])
      else
        not_found
      end
    else
      not_found
    end
  end

  def update
    if can? :tag, SolrDocument
      if ActsAsTaggableOn::Tag.exists? :id => params[:id]
        tag = ActsAsTaggableOn::Tag.find params[:id]
        logger.debug "Tag is nil? #{tag.nil?}"
        new_tag_name = params[:tag_name]

        if new_tag_name
          taggings_for_id(tag.id).map(&:taggable_id).each do |pointer_id|
            document = SolrDocumentPointer.find(pointer_id)
            remove_tag(current_user, document, tag.name)
            add_tag(current_user, document, new_tag_name)
          end
          redirect_to tags_path
        else
          not_found
        end
      else
        not_found
      end
    else
      not_found
    end
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
