module Toshokan
  module Catalog
    extend ActiveSupport::Concern

    included do
      include Toshokan::PerformsSearches
      include Toshokan::SearchesTags
      include Toshokan::AssociatesSearchesWithUsers
      include Toshokan::BuildsToc
      include Toshokan::MendeleyController

      helper_method :journal_id_for_issns
    end

    # Overrides Blacklight::Catalog#has_search_parameters? to know about DTU-specific query parameters
    def has_search_parameters?
      result = super || !params[:t].blank? || !params[:l].blank? || !params[:resolve].blank?
    end

    def export_search_result(format_name, params, extra_search_params)
      params.delete('per_page')
      params['page'] = 1
      params['rows'] = blacklight_config.max_per_page
      (response, document_list) = get_search_results(params, extra_search_params)

      case format_name
        when :bib
          # Add references to a BibTex::Bibliography to ensure that bibtex
          # keys are unique within exported file
          bibliography = BibTeX::Bibliography.new
          document_list.each do |document|
            bibliography.add(document.export_as(:bib))
          end
          bibliography.map{|entry| entry.to_s}.join("\n")
        when :ris
          document_list.map{|document| document.export_as(:ris)}.join("\n\n")
      end
    end

    ##
    # Add any existing limits, stored in app-level HTTP query
    # as :l, to solr as appropriate :fq query.
    def add_limit_fq_to_solr(solr_parameters, user_params)
      # :fq, map from :l.
      if ( user_params[:l])
        l_request_params = user_params[:l]

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

        solr_parameters
      end
    end

    def journal_document_for_issns(issns)
      response = get_solr_response_for_field_values("issn_ss", issns, add_access_filter({:fq => ['format:journal'], :rows => 1})).first
      documents = response[:response][:docs]
      documents.first unless documents.empty?
    end

    def journal_id_for_issns(issns)
      document = journal_document_for_issns(issns)
      document[:cluster_id_ss] if document
    end

    def journal
      id = journal_id_for_issns(params[:issn]) or not_found
      redirect_to catalog_path :id => id, :key => params[:key], :ignore_search => params[:ignore_search]
    end

  end
end