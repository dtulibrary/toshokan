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

  ##
  # Add any existing limits, stored in app-level HTTP query
  # as :l, to solr as appropriate :fq query.
  def add_limit_fq_to_solr(solr_parameters, user_params)
    # :fq, map from :l.
    if ( user_params[:l])
      l_request_params = user_params[:l]

      solr_parameters[:fq] ||= []
      l_request_params.each_pair do |l|
        limit_name = l.first
        limit_value = l.second

        field_config = blacklight_config[:limit_fields][limit_name]
        solr_parameters[:fq] << field_config[:fields].map { |field|
          "#{field}:\"#{limit_value}\""
        }.join(' OR ')

      end

      solr_parameters
    end
  end

  def limit_label(limit)
    field_config = blacklight_config[:limit_fields][limit]
    field_config[:label] || limit.titlecase
  end

  def limit_display_value(limit, value)
    field_config = blacklight_config[:limit_fields][limit]
    helper_method = field_config[:helper_method]
    helper_method && send(helper_method, limit, value) || value
  end

  def toc_limit_display_value(limit, value)
    issn, year, vol, issue = dissect_toc_key(value)
    title = journal_title_for_issns([issn])
    info = []
    info << "<em>#{title}</em>"
    info << year
    info << "Volume #{vol}" if vol > 0
    info << "Issue #{issue}"  if issue  > 0
    info.join(', ').html_safe
  end

end
