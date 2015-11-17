# -*- coding: utf-8 -*-
module Toshokan
  module SearchesTags

    extend ActiveSupport::Concern

    included do
      helper_method :any_tag_in_params?, :tag_in_params?, :add_tag_fq_to_solr
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
