module FieldFiltersHelper

  def filter_fields fields, document=nil
    filters = field_filters
    fields.select do |field_name, field|
      filters.select { |filter| filter.call(field, document)}.length == filters.length
    end
  end

  def field_filters
    filters = []

    # some fields are only for certain document types
    filters << Proc.new do |field, document|
      doc_format = document['format'] || ""
      field.format.nil? || field.format.include?(doc_format)
    end

    # do not show keywords from iel in public version
    filters << Proc.new do |field, document|
      !(field.field == "keywords_ts" && document.has_key?("source_ss") && document["source_ss"].include?("iel") && (can? :search, :public))
    end

    filters
  end

  def field_suppressed? document, solr_field
    suppressed = false
    if solr_field.suppressed_by
      solr_field.suppressed_by.each do |field_name|
        suppressed ||= document[field_name]
      end
    end
    suppressed
  end
end