module BlacklightConfigurationHelper
  include Blacklight::ConfigurationHelperBehavior

  # used in the catalog/_show/_default partial
  def document_show_fields document=nil
    filter_fields blacklight_config.show_fields, document
  end

  ##
  # Index fields to display for a type of document
  def index_fields document=nil
    filter_fields blacklight_config.index_fields, document
  end

end
