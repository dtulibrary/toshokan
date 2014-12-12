# -*- coding: utf-8 -*-
module Toshokan
  module SearchesTags

    extend ActiveSupport::Concern

    included do
      helper_method :any_tag_in_params?, :tag_in_params?, :add_tag_fq_to_solr
    end

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
