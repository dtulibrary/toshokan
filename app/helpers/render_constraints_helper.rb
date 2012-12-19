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
       content << render_tag_element(tag, localized_params)
    end

    return content.flatten.join("\n").html_safe
  end

  def render_tag_element(tag, localized_params)
    render_constraint_element(Tag.reserved?(tag.first) ? I18n.t('toshokan.tags.bookmarked') : I18n.t('toshokan.tags.tagged'),
		Tag.reserved?(tag.first) ? tag.first[1..-1] : tag.first,
                :remove => url_for(remove_tag_params(tag.first, localized_params)),
                :classes => ["filter", "tag-" + tag.first]
              ) + "\n"
  end

end
