module Toshokan
  module AssociatesSearchesWithUsers
    extend ActiveSupport::Concern

    included do
      after_filter :associate_search_with_user, only:[:index]
    end

    def associate_search_with_user
      if current_search_session
        current_user.searches << current_search_session
        current_search_session.save
      end
    end

    def inject_last_query_into_params
      if current_search_session
        current_search_params = current_search_session.query_params.empty? ? {} : current_search_session.query_params
        params.merge!(current_search_params.reject {|k,v| ["controller","action"].include?(k)}) unless params[:ignore_search]
      end
    end

  end
end
