module Toshokan
  module MendeleyController
    extend ActiveSupport::Concern

    included do
      before_filter :authenticate_mendeley, :only => [:mendeley_index, :mendeley_show]
    end

    def mendeley_index
      respond_to do |format|
        format.html do
          extra_search_params = {:rows => 0, :facet => false, :stat => false}
          (@response, @document_list) = get_search_results(params, extra_search_params)
          @num_found = @response['response']['numFound']
          @max_export = blacklight_config.max_per_page
          @export_id  = SecureRandom.uuid
          @folders, @groups = mendeley_folders_and_groups
          render layout: 'external_page'
        end
      end
    end

    def mendeley_index_save
      extra_search_params = {:rows => blacklight_config.max_per_page, :facet => false, :stat => false}
      (@response, @document_list) = get_search_results(params, extra_search_params)
      save_to_mendeley @document_list, params['folder'], params['tags'].split(',').map(&:strip), {:progress_name => params['export_id']}
      respond_to do |format|
        format.html do
          render :inline => 'Saved', layout: 'external_page'
        end
        format.js do
          render :js => ''
        end
      end
    end

    def mendeley_show
      (@response, @document) = get_solr_response_for_doc_id nil, {:fq => ["access_ss:#{Rails.application.config.search[:dtu]}"]}
      @folders, @groups = mendeley_folders_and_groups
      respond_to do |format|
        format.html do
          render layout: 'external_page'
        end
      end
    end

    def mendeley_show_save
      (@response, @document) = get_solr_response_for_doc_id nil, {:fq => ["access_ss:#{Rails.application.config.search[:dtu]}"]}
      save_to_mendeley [@document], params['folder'], params['tags'].split(',').map(&:strip)
      respond_to do |format|
        format.html do
          render :inline => 'Saved', layout: 'external_page'
        end
        format.js do
          render :js => ''
        end
      end
    end

    def mendeley_authenticated?
      session[:mendeley_access_token] && Time.at(session[:mendeley_access_token].expires_at) > Time.now
    end

    def authenticate_mendeley
      unless mendeley_authenticated?
        session.delete(:mendeley_access_token)
        redirect_to "/auth/mendeley/login?#{ {:url => request.url}.to_query }"
      end
    end

  end
end
