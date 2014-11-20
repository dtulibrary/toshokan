module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  # Determine if Blacklight should always render the facet expanded
  #
  # By default, only render facets with items.
  # @param [String] facet_name
  def should_always_expand_facet(facet_name)
    facet_configuration_for_field(facet_name).always_expand
  end

  # Overrides facet_display_value to use i18n names for document formats (article, book, etc.)
  def facet_display_value field, item
    if field == 'format'
      item = Blacklight::SolrResponse::Facets::FacetItem.new(item) unless item.respond_to? :label
      item.label = t "toshokan.catalog.formats.#{item.label}"
    end
    super
  end

  def render_facet_count num, options = {}
    super number_with_delimiter(num), options
  end
end
