
# mimics an rsolr-ext response for a grouped solr response 
class GroupedSolrResponse < RSolr::Ext::Response::Base
  
  def initialize hash, handler, request_params
    @original_hash = hash.with_indifferent_access    
    @request_path, @request_params = request_path, request_params

    extend RSolr::Ext::Response::Facets
    extend RSolr::Ext::Response::Spelling  
  end
  
  def [] key
    @original_hash[key]
  end  
  
  def response
    # hack to handle variations in solr response structure
    (self["grouped"].is_a? Array) ? self["grouped"].last : self["grouped"].values.first
  end

  def total
    response["ngroups"].to_s.to_i
  end

  def start
    params["start"].to_i
  end

  def rows
    params["rows"].to_i
  end
  
  def docs
    response["groups"].collect {|group| group["doclist"]["docs"].first}
  end  
  
end  