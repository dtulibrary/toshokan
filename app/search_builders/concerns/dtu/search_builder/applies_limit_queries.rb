module Dtu
  class SearchBuilder
    module AppliesLimitQueries
      ##
      # Add any existing limits, stored in app-level HTTP query
      # as :l, to solr as appropriate :fq query.
      def add_limit_fq_to_solr(solr_parameters)
        # :fq, map from :l.
        if ( blacklight_params[:l] || blacklight_params['l'])
          l_request_params = blacklight_params.with_indifferent_access[:l]

          solr_parameters[:fq] ||= []
          l_request_params.each_pair do |l|
            limit_name = l.first
            limit_value = l.second
            if limit_value.is_a? Hash
              limit_value = limit_value[:value]
            end

            field_config = blacklight_config[:limit_fields][limit_name]
            solr_parameters[:fq] << field_config[:fields].map { |field|
              "#{field}:\"#{limit_value}\""
            }.join(' OR ')
          end
        end
      end

    end
  end
end
