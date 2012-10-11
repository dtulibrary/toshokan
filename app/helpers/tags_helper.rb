module TagsHelper

  def tag_control(document)
    solr_document_pointer = SolrDocumentPointer.find_by_solr_id(document.id)
    tags = []
    tags = solr_document_pointer.tags_from(current_user).map{|name| ActsAsTaggableOn::Tag.find_by_name(name)} if solr_document_pointer
    render(:partial => 'tags/tag_control', :locals => {:document => document, :tags => tags})
  end

  def render_tag_partials options={}
    options = options.dup
    options[:partial] = "tags/tags"
    options[:locals] ||= {}
    options[:locals][:tags] ||= current_user.owned_tags
    render(options)
  end

  def render_tag_value(tag, options ={})
    (link_to_unless(options[:suppress_link], tag.name, add_tag_params_and_redirect(tag.name), :class=>"tag_select label")).html_safe
  end

  # Adds the tag to params[:t]
  # Does NOT remove request keys and otherwise ensure that the hash
  # is suitable for a redirect. See
  # add_facet_params_and_redirect
  def add_tag_params(tag)
    p = params.dup
    p[:t] = {tag => 'true'}
    p
  end

  # Add on the tag params to existing
  # search constraints. Remove any paginator-specific request
  # params, or other request params that should be removed
  # for a 'fresh' display.
  # Change the action to 'index' to send them back to
  # catalog/index with their new tag choice.
  def add_tag_params_and_redirect(tag)
    new_params = add_tag_params(tag)

    # Delete page, if needed.
    new_params.delete(:page)

    Blacklight::Solr::FacetPaginator.request_keys.values.each do |paginator_key|
      new_params.delete(paginator_key)
    end
    new_params.delete(:id)

    # Force action to be index.
    new_params[:action] = "index"
    new_params
  end

  # copies the current params (or whatever is passed in as the 3rd arg)
  # removes the tag name from params[:t]
  # removes additional params (page, id, etc..)
  def remove_tag_params(tag, source_params=params)
    p = source_params.dup
    # need to dup the facet values too,
    # if the values aren't dup'd, then the values
    # from the session will get remove in the show view...
    p[:t] = (p[:t] || {}).dup
    p.delete :page
    p.delete :id
    p.delete :counter
    p.delete :commit
    p[:t].delete(tag)
    p
  end

  ##
  # Add any existing tag filters, stored in app-level HTTP query
  # as :t, to solr as appropriate :fq query.
  def add_tag_fq_to_solr(solr_parameters, user_params)
    # :fq, map from :t.
    if ( user_params[:t])
      t_request_params = user_params[:t]

      solr_parameters[:fq] ||= []
      t_request_params.each_pair do |t|
        tag = current_user.owned_tags.where(name: t).first
        if tag
          pointer_ids = current_user.owned_taggings.where(tag_id: tag.id).map(&:taggable_id)
          solr_ids = SolrDocumentPointer.find(pointer_ids).map(&:solr_id)
          solr_parameters[:fq] << "cluster_id:(#{solr_ids.join(' OR ')})"
        else
          solr_parameters[:fq] << "cluster_id:(NOT *)"
        end

      end
    end
  end

  # true or false, depending on whether any tag name is in params
  def any_tag_in_params?
    params[:t] != nil
  end

  # true or false, depending on whether the tag name is in params[:t]
  def tag_in_params?(tag)
    params[:t] and params[:t][tag.name] and params[:t][tag.name] == 'true'
  end
end
