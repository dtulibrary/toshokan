module Toshokan
  module SearchesTags

    extend ActiveSupport::Concern

    included do
      helper_method :any_tag_in_params?, :tag_in_params?
    end

    ##
    # Add any existing tag filters, stored in app-level HTTP query
    # as :t, to solr as appropriate :fq query.
    def add_tag_fq_to_solr(solr_parameters, user_params)
      # :fq, map from :t.
      if ( user_params[:t])
        t_request_params = user_params[:t]
        solr_parameters[:fq] ||= []
        t_request_params.each_pair do |t|
          document_ids = []
          tag_name = t.first
          if tag_name == Tag.reserved_tag_all
            document_ids = current_user.bookmarks.map(&:document_id);
          elsif tag_name == Tag.reserved_tag_untagged
            document_ids = current_user.bookmarks.find_all{|b| b.taggings.empty?}.map(&:document_id);
          else
            tag = current_user.tags.find_by_name(tag_name)
            if tag
              document_ids = tag.bookmarks.map(&:document_id)
            end
          end

          if not document_ids.empty?
            solr_parameters[:fq] << "#{SolrDocument.unique_key}:(#{document_ids.join(' OR ')})"
          else
            solr_parameters[:fq] << "#{SolrDocument.unique_key}:(NOT *)"
          end
        end

      end
    end

    # true or false, depending on whether any tag name is in params
    def any_tag_in_params?
      params[:t] != nil
    end

    # true or false, depending on whether the tag name is in params[:t]
    def tag_in_params?(tag_name)
      params[:t] and params[:t][tag_name] and params[:t][tag_name] == '✓'
    end

    # True or false depending on whether the user has any tags
    def tags_empty?
      current_or_guest_user.owned_tags.empty?
    end
  end
end