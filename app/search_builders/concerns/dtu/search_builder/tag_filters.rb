module Dtu
  class SearchBuilder
    module TagFilters
      # Add any existing tag filters, stored in app-level HTTP query
      # as :t, to solr as appropriate :fq query.
      def add_tag_fq_to_solr(solr_parameters)
        t_request_params = blacklight_params.with_indifferent_access[:t]
        if t_request_params
          solr_parameters[:fq] ||= []
          t_request_params.each_pair do |t|
            tag_name = t.first
            document_ids = document_ids_for_tag_name(tag_name)
            solr_parameters[:fq] << fq_for_document_ids(document_ids)
          end
        end
      end

      def fq_for_document_ids(document_ids)
        if !document_ids.empty?
          "#{::SolrDocument.unique_key}:(#{document_ids.join(' OR ')})"
        else
          "#{::SolrDocument.unique_key}:(NOT *)"
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
    end
  end
end
