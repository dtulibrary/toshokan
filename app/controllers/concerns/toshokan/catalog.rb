module Toshokan
  module Catalog
    extend ActiveSupport::Concern

    included do
      include Toshokan::PerformsSearches
      include Toshokan::SearchesTags
      include Toshokan::AssociatesSearchesWithUsers
      include Toshokan::BuildsToc
      include Toshokan::MendeleyController
      include Toshokan::NormalizesYears

      helper_method :journal_id_for_issns
    end

    # Overrides Blacklight::Catalog#has_search_parameters? to know about DTU-specific query parameters
    def has_search_parameters?
      result = super || !params[:t].blank? || !params[:l].blank? || !params[:resolve].blank?
    end

    def export_search_result(format_name, params)
      params.delete('per_page')
      params['page'] = 1
      params['rows'] = blacklight_config.max_per_page
      (response, document_list) = search_results(params, search_builder_class.default_processor_chain)

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

    def journal_document_for_issns(issns)
      response = get_solr_response_for_field_values("issn_ss", issns, search_builder.add_access_filter({:fq => ['format:journal'], :rows => 1})).first
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
