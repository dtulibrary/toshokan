module SearchHistoryConstraintsHelper
  include Blacklight::SearchHistoryConstraintsHelperBehavior

  def render_search_to_s(params)
    super +
    render_search_to_s_limits(params)
  end

  def render_search_to_s_limits(params)
    return ''.html_safe unless params[:l]

    params[:l].collect do |limit, value|
      render_search_to_s_element(limit_label(limit), limit_display_value(limit, value))
    end.join(" \n ").html_safe

  end

  def render_search_to_s_tags(params)
    return "".html_safe unless params[:t]

    params[:t].collect do |tag_name, value_list|
      if Tag.reserved?(tag_name)
        render_search_to_s_element(I18n.t('toshokan.tags.bookmarks'),
				  case tag_name when Tag.reserved_tag_all
						  I18n.t('toshokan.tags.all')
						when Tag.reserved_tag_untagged
						  I18n.t('toshokan.tags.untagged')
				  end)
      else
      render_search_to_s_element(I18n.t('toshokan.tags.tagged'), tag_name)
      end
    end.join(" \n ").html_safe
  end


end
