
# mimics an rsolr-ext response for a grouped solr response 
class GroupedSolrResponse < RSolr::Ext::Response::Base
  
  def initialize hash, handler, request_params
    #super hash
    @original_hash = hash
    @request_path, @request_params = request_path, request_params
    #extend RSolr::Ext::Response
    #extend Docs
    extend RSolr::Ext::Response::Facets
    extend RSolr::Ext::Response::Spelling  
  end
  
  def [] key
    @original_hash[key]
  end  
  
  def response
    self["grouped"].last
  end

  # short cut to response['numFound']
  def total
    response["ngroups"].to_s.to_i
  end

  def start
    response[:start].to_s.to_i
  end

  def rows
    params["rows"].to_i
  end
  
  def docs
    response["groups"].collect {|group| group["doclist"]["docs"].first}
  end  
  
end  