module RefineSearchHelper
  def refine_search_enabled?
    ((Rails.configuration.respond_to?(:freecite)) && (not Rails.configuration.freecite[:url].nil?) && (Rails.configuration.freecite[:enabled] == true))
  end
end
