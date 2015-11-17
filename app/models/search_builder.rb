class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Toshokan::SearchParametersHelpers

  self.default_processor_chain += [:add_tag_fq_to_solr]
  self.default_processor_chain += [:add_limit_fq_to_solr]
  self.default_processor_chain += [:add_access_filter]
  self.default_processor_chain += [:add_format_filter]


  ## TAGS

  # Add any existing tag filters, stored in app-level HTTP query
  # as :t, to solr as appropriate :fq query.
  def add_tag_fq_to_solr(solr_parameters, user_params)
    return false unless user_params[:t]

    t_request_params = user_params[:t]
    solr_parameters[:fq] ||= []
    t_request_params.each_pair do |t|
      tag_name = t.first
      document_ids = document_ids_for_tag_name(tag_name)
      solr_parameters[:fq] << fq_for_document_ids(document_ids)
    end
  end

  def fq_for_document_ids(document_ids)
    if !document_ids.empty?
      "#{SolrDocument.unique_key}:(#{document_ids.join(' OR ')})"
    else
      "#{SolrDocument.unique_key}:(NOT *)"
    end
  end

  def document_ids_for_tag_name(tag_name)
    if tag_name == Tag.reserved_tag_all
      document_ids = current_user.bookmarks.map(&:document_id)
    elsif tag_name == Tag.reserved_tag_untagged
      tagged_bookmarks = current_user.bookmarks.select { |b| b.taggings.empty? }
      document_ids = tagged_bookmarks.map(&:document_id)
    else
      tag = current_user.tags.find_by_name(tag_name)
      document_ids = tag.bookmarks.map(&:document_id) if tag
    end
    document_ids
  end

  ## /TAGS

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

end
