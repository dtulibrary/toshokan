# -*- encoding : utf-8 -*-

module RenderConstraintsHelper
  include Blacklight::RenderConstraintsHelperBehavior

  def search_params localized_params = params
    result = {}.with_indifferent_access

    (!params[:ignore_search] && session[:search] || {}).each do |k,v|
      result[k] = params.has_key?(k) ? params[k] : v
    end
    result
  end

  def query_has_constraints?(localized_params = params)
    localized_params = search_params localized_params
    super or !(localized_params[:t].blank?) or !(localized_params[:l].blank?) or query_has_advanced_search_constraints?(localized_params)
  end

  def query_has_advanced_search_constraints? localized_params = params
    result = false
    advanced_search_fields.each do |field_name, field|
      result ||= !(localized_params[field_name].blank?)
    end
    result
  end

  def render_constraints(localized_params = params)
    localized_params = search_params localized_params
    (render_constraints_filters(localized_params) + render_constraints_limits(localized_params) + render_constraints_tags(localized_params) + render_advanced_search_constraints(localized_params)).html_safe
  end

  def render_constraints_limits(localized_params = params)
    return "".html_safe unless localized_params[:l]
    content = []
    localized_params[:l].each_pair do |limit|
      content << render_limit_element(limit.first, limit.second, localized_params)
    end

    return content.flatten.join("\n").html_safe
  end

  def render_constraints_tags(localized_params = params)
    return "".html_safe unless localized_params[:t]
    content = []
    localized_params[:t].each_pair do |tag|
       content << render_tag_element(tag.first, localized_params)
    end

    return content.flatten.join("\n").html_safe
  end

  def render_advanced_search_constraints localized_params = params
    content = []
    advanced_search_fields.each do |field_name, field|
      unless localized_params[field_name].blank?
        content << render_advanced_search_constraint(field_name, params)
      end
    end
    content.flatten.join("\n").html_safe
  end

  def render_advanced_search_constraint field_name, localized_params = params
    logger.debug "field name = #{field_name}"
    render_constraint_element(I18n.t("toshokan.catalog.search_field_labels.#{field_name}"), 
      field_name == 'format' ? I18n.t("toshokan.catalog.formats.#{localized_params[field_name]}") : localized_params[field_name],
      :remove => url_for(:controller => 'catalog', :action => 'index', :params => localized_params.reject { |k,v| k == field_name }),
      :classes => ['filter']
    )
  end

  def render_tag_element(tag_name, localized_params)
    if Tag.reserved?(tag_name)
      render_constraint_element(I18n.t('toshokan.tags.bookmarks'),
				case tag_name when Tag.reserved_tag_all
						I18n.t('toshokan.tags.all')
					      when Tag.reserved_tag_untagged
						I18n.t('toshokan.tags.untagged')
				end,
				:remove => url_for(remove_tag_params(tag_name, localized_params)),
				:classes => ["filter", "tag-" + tag_name, "tag-constraint"]
				) + "\n"
    else
      render_constraint_element(I18n.t('toshokan.tags.tagged'),
				tag_name,
				  :remove => url_for(remove_tag_params(tag_name, localized_params)),
				  :classes => ["filter", "tag-" + tag_name, "tag-constraint"]
				) + "\n"
    end
  end

  def render_limit_element(limit, value, localized_params)
    options = {:classes => ['filter', 'limit', 'limit-' + limit.parameterize]}

    options[:remove] = url_for(remove_limit_params(limit, localized_params))
    render_constraint_element(limit_label(limit), limit_display_value(limit, value), options) + "\n"
  end

  def render_filter_element(facet, values, localized_params)
    facet_config = facet_configuration_for_field(facet)

    options = {:classes => ['filter', 'filter-' + facet.parameterize]}

    values.map do |val|
      options[:remove] = url_for(remove_facet_params(facet, val, localized_params)) unless @disable_remove_filter 
      render_constraint_element(facet_field_labels[facet], facet_display_value(facet, val), options) + "\n"    
    end 
  end 

end
