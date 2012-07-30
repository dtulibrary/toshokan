
module GroupedDocs 
  include RSolr::Ext::Response::Docs
    
  def self.extended(base)
      d = base['response']['docs']
      # TODO: could we do this lazily (Enumerable etc.)
      d.each{|doc| doc.extend RSolr::Ext::Doc }
      d.extend Pageable
      d.per_page = [base.rows, 1].max
      d.start = base.start
      d.total = base.total
    end
    
end  