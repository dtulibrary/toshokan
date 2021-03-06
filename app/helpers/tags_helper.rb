# -*- encoding : utf-8 -*-
module TagsHelper

  def render_tag_control(document)
    bookmark = current_user.bookmarks.find_by_document_id(document.id)
    tags = bookmark ? bookmark.tags.order(:name) : []
    tags = current_user.tags.order(:name)

    return_url = request.url
    if params && params[:return_url]
      return_url = params[:return_url]
    end

    render 'tags/tag_control',
           {:document => document, :document_id => document.id, :bookmark => bookmark, :tags => tags, :return_url => return_url}
  end

  def render_tag_partials options={}
    options = options.dup
    options[:partial] = "tags/tags"
    options[:locals] ||= {}
    options[:locals][:tags] ||= current_or_guest_user.tags.order(:name)
    render(options)
  end

  def render_tag_list options={}
    options = options.dup
    options[:partial] = "tags/tags_list"
    options[:locals] ||= {}
    options[:locals][:tags] ||= Tag.reserved_tags.map{|t| OpenStruct.new(:name => t)} + current_or_guest_user.tags.order(:name)

    if request.xhr? and controller.params and controller.params[:return_url]
      # if this is an ajax call, we are given a return_url that represents the original request
      # we replace the params hash with the one from the original url to generate correct links
      # for tag facets in the ajax-rendered tags_list

      return_url = controller.params[:return_url]
      params_from_return_url = Rack::Utils.parse_nested_query(URI::parse(return_url).query)
      params_from_return_url.merge! params.slice(:refresh)
      controller.params = params_from_return_url.with_indifferent_access
    end

    options[:locals][:tags].each do |tag|
      tag.count = count_documents_for_tag_and_search(tag, controller.params)
    end

    render(options)
  end

  def count_documents_for_tag_and_search(tag, params)
    extra_search_params = {:rows => 0, :facet => false, :stat => false}
    params = params.dup
    params[:t] = {tag.name => '✓'}
    (response, _) = controller.get_search_results(params, extra_search_params)
    response['response']['numFound']
  end

  def render_tags_for_document(document)
    render 'catalog/tags', {:document => document}
  end

  def render_tags_as_labels(document)
    bookmark = current_user.bookmarks.find_by_document_id(document.id)

    return_url = request.url
    if params && params[:return_url]
      return_url = params[:return_url]
    end

    render 'tags/tags_as_labels', {:bookmark => bookmark, :return_url => return_url}
  end

  def tag_display_icon(tag_name)
    case tag_name
    when Tag.reserved_tag_all
      content_tag(:i, '', :class => 'glyphicon glyphicon-star red')
    when Tag.reserved_tag_untagged
      content_tag(:i, '', :class => 'glyphicon glyphicon-tag')
    else
      content_tag(:i, '', :class => 'glyphicon glyphicon-tag red')
    end
  end

  def tag_display_name(tag_name, options={})
    case tag_name
    when Tag.reserved_tag_all, Tag.reserved_tag_untagged
      tag_name[1..-1]
    else
      tag_name
    end
  end

  def tag_display(tag_name, options={})
    (options[:suppress_icon] ? '' : tag_display_icon(tag_name)) + tag_display_name(tag_name)
  end

  def render_tag_value(tag_name, options={})
    link_to_unless(options[:suppress_link], tag_display(tag_name, options),
                   add_tag_params_and_redirect(tag_name),
                   :class=>"facet_select").html_safe
  end

  def render_selected_tag_value(tag_name, options ={})
    options = options.merge({:suppress_link => true})
    content_tag(:span,
                tag_display(tag_name, options),
                :class => "selected") +
      link_to(content_tag(:i, '', :class => "glyphicon glyphicon-remove") +
                content_tag(:span, '[remove]', :class => 'sr-only'),
              remove_tag_params(tag_name, params),
              :class=>"remove")
  end

  # Adds the tag to params[:t]
  # Does NOT remove request keys and otherwise ensure that the hash
  # is suitable for a redirect. See
  # add_tag_params_and_redirect
  def add_tag_params(tag)
    new_params = params.dup
    new_params[:t] = {tag => '✓'}
    new_params
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
    new_params[:controller] = "catalog"
    new_params[:action] = "index"
    new_params
  end

  # copies the current params (or whatever is passed in as the 3rd arg)
  # removes the tag name from params[:t]
  # removes additional params (page, id, etc..)
  def remove_tag_params(tag, source_params=params)
    new_params = source_params.dup

    # need to dup the facet values too,
    # if the values aren't dup'd, then the values
    # from the session will get remove in the show view...
    new_params[:t] = (new_params[:t] || {}).dup
    new_params.delete :page
    new_params.delete :id
    new_params.delete :counter
    new_params.delete :commit
    new_params[:t].delete(tag)

    # Force action to be index.
    new_params[:controller] = "catalog"
    new_params[:action] = "index"
    new_params
  end

end
