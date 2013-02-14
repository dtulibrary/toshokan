module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  # Determine if Blacklight should always render the facet expanded
  #
  # By default, only render facets with items.
  # @param [String] facet_name
  def should_always_expand_facet(facet_name)
    facet_configuration_for_field(facet_name).always_expand
  end
end
