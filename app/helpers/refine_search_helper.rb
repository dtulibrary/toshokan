module RefineSearchHelper
  def refine_search_configured?
    ((Rails.configuration.respond_to?(:freecite)) && (not Rails.configuration.freecite[:url].nil?))
  end
end
