module SearchHistoryConstraintsHelper
  include Blacklight::SearchHistoryConstraintsHelperBehavior

  def render_search_to_s(params)
    super +
    render_search_to_s_limits(params)
  end

  def render_search_to_s_limits(params)
    return ''.html_safe unless params[:l]

    params[:l].map do |limit, value|
      render_search_to_s_element(limit_label(limit), limit_display_value(limit, value))
    end.join(" \n ").html_safe
  end
end
