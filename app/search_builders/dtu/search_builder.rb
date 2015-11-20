module Dtu
  class SearchBuilder < Blacklight::SearchBuilder
    include Blacklight::Solr::SearchBuilderBehavior
    include Dtu::SearchBuilder::AccessFilters
    include Dtu::SearchBuilder::AppliesLimitQueries
    include Dtu::SearchBuilder::TagFilters

    self.default_processor_chain += [:handle_resolver_params]
    self.default_processor_chain += [:add_tag_fq_to_solr]
    self.default_processor_chain += [:add_limit_fq_to_solr]
    self.default_processor_chain += [:add_access_filter]
    self.default_processor_chain += [:add_format_filter]

    def current_user
      scope.current_user
    end

    def handle_resolver_params(solr_parameters)
      if blacklight_params[:from_resolver]
        solr_parameters.merge blacklight_config[:resolver_params]
      end
    end

  end
end
