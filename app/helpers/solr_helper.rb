module SolrHelper

  # Make Blacklight::SolrHelper#get_solr_response_for_field_values available as helper_method
  # since we usually call journal_{id,title}_for_issns from view

  def self.included(base)
    base.send :helper_method, :get_solr_response_for_field_values if base.respond_to? :helper_method
  end

  def add_access_filter solr_parameters = {}, user_parameters = {}
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << 'access_ss:dtu' if can? :search, :dtu
    solr_parameters[:fq] << 'access_ss:dtupub' if can? :search, :public
    solr_parameters
  end

  def journal_document_for_issns(issns)
    response = get_solr_response_for_field_values("issn_ss", issns, add_access_filter({:fq => ['format:journal'], :rows => 1})).first
    documents = response[:response][:docs]
    documents.first unless documents.empty?
  end

  def article_document_for_issns(issns)
    response = get_solr_response_for_field_values("issn_ss", issns, add_access_filter({:fq => ['format:article'], :rows => 1})).first
    documents = response[:response][:docs]
    documents.first unless documents.empty?
  end

  def journal_id_for_issns(issns)
    document = journal_document_for_issns(issns)
    document[:cluster_id_ss] if document
  end

  def journal_title_for_issns(issns)
    document = journal_document_for_issns(issns)
    # first try to find the journal record
    if document && document[:title_ts]
      document[:title_ts].first
    else
      # fall back to article records if not found
      document = article_document_for_issns(issns)
      document && document[:journal_title_ts].first || !issns.empty? && issns.first
    end
  end

end
