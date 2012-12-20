# -*- encoding : utf-8 -*-

module RenderConstraintsHelper
  include Blacklight::RenderConstraintsHelperBehavior

  def query_has_constraints?(localized_params = params)
    super or !(localized_params[:t].blank?)
  end

  def render_constraints(localized_params = params)
    (super + render_constraints_tags(localized_params)).html_safe
  end

  def render_constraints_tags(localized_params = params)
    return "".html_safe unless localized_params[:t]
    content = []
    localized_params[:t].each_pair do |tag|
       content << render_tag_element(tag.first, localized_params)
    end

    return content.flatten.join("\n").html_safe
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
				:classes => ["filter", "tag-" + tag_name]
				) + "\n"
    else
      render_constraint_element(I18n.t('toshokan.tags.tagged'),
				tag_name,
				  :remove => url_for(remove_tag_params(tag_name, localized_params)),
				  :classes => ["filter", "tag-" + tag_name]
				) + "\n"
    end
  end

end
