module Dtu
  class SearchBuilder
    module AccessFilters
      def add_format_filter solr_parameters = {}, user_parameters = {}
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << "format:(article OR book OR journal OR thesis OR other)"
        solr_parameters
      end

      def add_access_filter solr_parameters = {}, user_parameters = {}
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << "access_ss:#{Rails.application.config.search[:dtu]}" if scope.can? :search, :dtu
        solr_parameters[:fq] << "access_ss:#{Rails.application.config.search[:pub]}" if scope.can? :search, :public
        solr_parameters
      end

      def add_inclusive_access_filter solr_parameters = {}, user_parameters = {}
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << "access_ss:(#{Rails.application.config.search[:dtu]} OR #{Rails.application.config.search[:pub]})"
        solr_parameters
      end
    end
  end
end
