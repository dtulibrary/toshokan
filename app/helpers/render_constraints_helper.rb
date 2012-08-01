module RenderConstraintsHelper
  include Blacklight::RenderConstraintsHelperBehavior

  # Render actual constraints, not including header or footer
  # info.
  def render_constraints(localized_params = params)
    logger.debug localized_params.inspect
    (render_constraints_query(localized_params) + render_constraints_filters(localized_params) + render_constraints_tags(localized_params)).html_safe
  end

  def render_constraints_tags(localized_params = params)
    return "".html_safe unless localized_params[:t]
    content = []
    localized_params[:t].each_pair do |tag|
       content << render_tag_element(tag, localized_params)
    end

    return content.flatten.join("\n").html_safe
  end

  def render_tag_element(tag, localized_params)
    render_constraint_element( "Tag",
                tag.first,
                :remove => url_for(remove_tag_params(tag.first, localized_params)),
                :classes => ["filter", "tag-" + tag.first]
              ) + "\n"
  end

end