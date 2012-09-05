module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def has_search_parameters?
    super or !params[:t].blank?
  end

end
