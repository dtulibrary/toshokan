module SolrHelperExtension
	extend ActiveSupport::Concern
	include Blacklight::SolrHelper

  # a solr query method
  # given a user query, return a solr response containing both result docs and facets
  # - mixes in the Blacklight::Solr::SpellingSuggestions module
  #   - the response will have a spelling_suggestions method
  # Returns a two-element array (aka duple) with first the solr response object,
  # and second an array of SolrDocuments representing the response.docs
  def get_search_results(user_params = params || {}, extra_controller_params = {})

    # In later versions of Rails, the #benchmark method can do timing
    # better for us. 
    bench_start = Time.now

    solr_response = find_with_groups(self.solr_search_params(user_params).merge(extra_controller_params))  
    document_list = solr_response.response["groups"].collect {|doc| SolrGroup.new(doc, solr_response)}
    Rails.logger.debug("Solr fetch: #{self.class}#get_search_results (#{'%.1f' % ((Time.now.to_f - bench_start.to_f)*1000)}ms)")
    
    return [solr_response, document_list]
  end
  
  def get_solr_response_for_doc_id
    id = params["id"]
    solr_response = find_with_groups({:q => "cluster_id:#{id}"})  
    document = SolrGroup.new(solr_response.response["groups"].first, solr_response) 
    return [solr_response, document]
  end    
  
  def find_with_groups(search_params)
    logger.info(search_params)
    begin
      solr = RSolr.connect Blacklight.solr_config.merge({:read_timeout => 120, :open_timeout => 120})
      cache_key = search_params.hash.to_s
      header = Rails.cache.exist?(cache_key)? Hash["If-None-Match" => Rails.cache.read(cache_key)[:etag]] : {}  
      solr_response = solr.get "ds_group", :params => search_params, :headers => header
      Rails.cache.write(cache_key, {:etag => solr_response.response[:headers]["etag"].first, :response => solr_response})
    rescue RSolr::Error::Http => e
      if(e.response[:status]==304)
        # not modified, get response from cache
        solr_response = Rails.cache.read(cache_key)[:response]  
      else
        raise e  
      end
    end

    GroupedSolrResponse.new(solr_response, "", search_params)

  end  
  
  def get_single_doc_via_search(index, request_params)
    solr_params = solr_search_params(request_params)
    solr_params[:start] = (index - 1) # start at 0 to get 1st doc, 1 to get 2nd.    
    solr_params[:rows] = 1
    solr_params[:fl] = '*'
    solr_response = find_with_groups(solr_params)

    SolrGroup.new(solr_response.response["groups"].first, solr_response) unless solr_response.docs.empty?
  end
end