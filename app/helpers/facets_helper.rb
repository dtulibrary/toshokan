module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  # Determine if Blacklight should always render the facet expanded
  #
  # By default, only render facets with items.
  # @param [String] facet_name
  def should_always_expand_facet(facet_name)
    facet_configuration_for_field(facet_name).always_expand
  end

  def render_facet_value facet_solr_field, item, options = {}
    item.label = t "toshokan.catalog.formats.#{item.label}" if facet_solr_field == 'format'
    super facet_solr_field, item, options
  end

  def render_facet_count num, options = {}
    super number_with_delimiter(num), options
  end
end
