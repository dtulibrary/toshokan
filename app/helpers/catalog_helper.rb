module CatalogHelper
  include Blacklight::CatalogHelperBehavior

    def has_search_parameters?
    !params[:q].blank? or !params[:f].blank? or !params[:search_field].blank? or !params[:t].blank?
  end

end
