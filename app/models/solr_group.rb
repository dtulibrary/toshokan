# -*- encoding : utf-8 -*-
class SolrGroup 
  extend ActiveModel::Naming
  include RSolr::Ext::Doc

  @@source_type_priority = {
    'research' => 1,
    'publisher' => 2,
    'openaccess' => 3,
    'database' => 4,
    'aggregator' => 5,
    'unknown' => 6      
  }

  def initialize(group_values, solr_response)
    
    @group_values = group_values
    @solr_response = solr_response

    # select the member which will be used for display
    @member = primary_member
  end

  def member_id
    @member.data["id"]
  end  

  def id
    @group_values["groupValue"]
  end

  def [] key
    @member.data[key.to_s]
  end    
  
  def key?(key)
    self[key].present?
  end  
  
  def to_param
    id
  end  
  
  def export_formats
    {}
  end

  def source?(source)
    @members.any? {|member| member.source == source}
  end 
  
  def source_url(source)
    if self.source?(source) 
      member = @members.detect {|member| member.source == source}
      return member.data.key?("source_url") ? member.data["source_url"] : ""
    end  
  end 

  def to_partial_path
    'catalog/document'
  end

  private

  def primary_member
    @members = Array.new
    @group_values["doclist"]["docs"].each do |doc|
      @members.push GroupMember.new(doc, doc["source_type"], doc["source"])
    end
    @members.sort! {|x,y| @@source_type_priority[x.source_type] <=> @@source_type_priority[y.source_type]}
    @members.first
  end  

  class GroupMember

    attr_reader :data
    attr_reader :source_type
    attr_reader :source

    def initialize(data, source_type, source)
      @data = data
      @source_type = source_type
      @source = source
    end

  end  

end  