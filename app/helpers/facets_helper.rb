module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  # Overrides facet_display_value to use i18n names for document formats (article, book, etc.)
  def facet_display_value field, item
    if field == 'format'
      item = Blacklight::Solr::Response::Facets::FacetItem.new(item) unless item.respond_to? :label
      item.label = t "toshokan.catalog.formats.#{item.label}"
    elsif field == 'subformat_s'
      item = Blacklight::Solr::Response::Facets::FacetItem.new(item) unless item.respond_to? :label
      item.label = t "toshokan.catalog.subformats.#{item.label}"
    end
    super
  end

  def render_facet_count num, options = {}
    super number_with_delimiter(num), options
  end
end
