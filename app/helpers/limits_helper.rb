# -*- encoding : utf-8 -*-

module LimitsHelper

  # Set the filter in params[:l]
  def set_limit_params(limit, value)
    new_params = {}
    new_params[:l] = {limit => value}
    new_params
  end

  # Set the limit params in  search constraints.
  # Set the action to 'index' to send them back to
  # catalog/index with their new limit choice.
  def set_limit_params_and_redirect(limit, value)
    new_params = set_limit_params(limit, value)

    # Force action to be index.
    new_params[:controller] = "catalog"
    new_params[:action] = "index"
    new_params
  end

  # copies the current params (or whatever is passed in as the 3rd arg)
  # removes the limit name from params[:l]
  # removes additional params (page, id, etc..)
  def remove_limit_params(limit, source_params=params)
    new_params = source_params.dup

    # need to dup the facet values too,
    # if the values aren't dup'd, then the values
    # from the session will get remove in the show view...
    new_params[:l] = (new_params[:l] || {}).dup
    new_params.delete :page
    new_params.delete :id
    new_params.delete :counter
    new_params.delete :commit
    new_params[:l].delete(limit)

    # Force action to be index.
    new_params[:controller] = "catalog"
    new_params[:action] = "index"
    new_params
  end

  def limit_label(limit)
    field_config = blacklight_config[:limit_fields][limit]

    solr_field_label(
        :"blacklight.search.fields.limit.#{limit}",
        :"blacklight.search.fields.#{limit}",
        (field_config["label"] if field_config),
        limit.to_s.humanize
    )
  end

  def limit_display_value(limit, value)
    field_config = blacklight_config[:limit_fields][limit]
    helper_method = field_config[:helper_method]
    helper_method && send(helper_method, limit, value) || value
  end

  def toc_limit_display_value(limit, value)
    if value.is_a? Hash
      issn, year, vol, issue = dissect_toc_key(value[:value])
      title = value[:title] || issn
    else
      issn, year, vol, issue = dissect_toc_key(value)
      title = issn
    end
    info = []
    info << "<em>#{title}</em>"
    info << year
    info << "Volume #{vol}"   if vol > 0
    info << "Issue #{issue}"  if issue > 0
    info.join(', ').html_safe
  end

  def limit_in_params?(limit)
    params[:l] && params[:l][limit] != nil
  end

end
