module Toshokan
  module PerformsSearches
    extend ActiveSupport::Concern

    included do
      include Blacklight::Controller
      include Blacklight::SolrHelper
      include Blacklight::Catalog::SearchContext
      include Toshokan::SearchParametersHelpers

      self.solr_search_params_logic += [:add_tag_fq_to_solr]
      self.solr_search_params_logic += [:add_limit_fq_to_solr]
      self.solr_search_params_logic += [:add_access_filter]
    end

    # Overrides Blacklight::Catalog::SearchContext#find_or_initialize_search_session_from_params
    # If user is logged in, search in persisted Search records for the user instead of the session history
    def find_or_initialize_search_session_from_params params
      params_copy = params.reject { |k,v| blacklisted_search_session_params.include?(k.to_sym) or v.blank? }

      # Don't save default 'empty' search
      return if params_copy[:q].blank? && params_copy[:f].blank? && params_copy[:l].blank? && params_copy[:t].blank?

      if current_user
        past_searches = current_user.searches
      else
        past_searches = searches_from_history
      end

      saved_search = past_searches.select { |x| x.query_params == params_copy }.first

      if saved_search
        saved_search.updated_at = Time.now
        saved_search.save
        return saved_search
      else
        begin
          s = Search.create(:query_params => params_copy)
          add_to_search_history(s)
          return s
        end
      end
    end

  end
end
