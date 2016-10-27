class SuggestController < ApplicationController
  include Blacklight::SolrHelper

  def index
    respond_to do |format|
      format.json do
        render json: SuggestService.query(params[:q], params[:dictionary], blacklight_solr, suggest_endpoint)
      end
    end
  end

  def suggest_endpoint
    CatalogController.blacklight_config.autocomplete_path
  end
end
