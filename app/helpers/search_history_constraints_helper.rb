module SearchHistoryConstraintsHelper
  include Blacklight::SearchHistoryConstraintsHelperBehavior

  def render_search_to_s(params)
    super +
    render_search_to_s_tags(params)
  end

    def render_search_to_s_tags(params)
    return "".html_safe unless params[:t]

    params[:t].collect do |tag_name, value_list|
      render_search_to_s_element(reserved?(tag_name) ? I18n.t('toshokan.tags.saved') : I18n.t('toshokan.tags.tagged'),
	render_filter_value(reserved?(tag_name) ? tag_name[1..-1] : tag_name)).html_safe
    end.join(" \n ").html_safe
  end


end
