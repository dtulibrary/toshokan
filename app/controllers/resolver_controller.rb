class ResolverController < CatalogController

  include ResolverHelper

  def index

    # Remove rails routing params
    openurl_params = params.dup
    openurl_params.delete(:controller)
    openurl_params.delete(:action)

    # remove context object params
    params.slice!(:controller, :action)

    if(msg = redirect_to_sfx(openurl_params))

      log_resolver_request("Redirecting request to SFX, #{msg}", openurl_params, request)
      Rails.logger.info "Redirect to #{Rails.application.config.resolve[:sfx_url]}?#{openurl_params.to_query}"
      redirect_to "#{Rails.application.config.resolve[:sfx_url]}?#{openurl_params.to_query}&fromfindit=true"
    else

      context_object = to_open_url(openurl_params)

      if context_object.nil?
        log_resolver_request("Resolver could not create a valid openURL, redirecting request to SFX", openurl_params, request)
        Rails.logger.info "Redirect to #{Rails.application.config.resolve[:sfx_url]}?#{openurl_params.to_query}"
        redirect_to "#{Rails.application.config.resolve[:sfx_url]}?#{openurl_params.to_query}&fromfindit=true"
      else

        (count, @response, @document) = get_resolver_result(context_object.to_hash)

        Rails.logger.info "context_object #{context_object.kev}"

        case count
        when 0
          # Reference can not be found, create synthesized solr document from OpenURL
          log_resolver_request("Creating synthesized record", openurl_params, request)
          params[:resolve] = true
          @document = SolrDocument.create_from_openURL(context_object)
          render('catalog/show') and return
        when 1
          # One record is found from the reference
          log_resolver_request("Found record #{@document.id}", openurl_params, request)
          redirect_to catalog_path id: @document.id and return
        else
          # More records are found from the reference
          catalog_params = solr_params_to_blacklight_query(@response['responseHeader']['params'])
          catalog_params[:from_resolver] = true
          log_resolver_request("Found search result #{catalog_params} with #{@response['response']['numFound']} results", openurl_params, request)
          redirect_to catalog_index_path catalog_params and return
        end
      end
    end
  end

  def search_action_url
    catalog_index_url
  end

  private

  def redirect_to_sfx(params)
    if params.has_key?("sfx.response_type") && ["simplexml", "multi_obj_xml"].include?(params["sfx.response_type"])
      msg = "request contains sfx response type"
    elsif params.has_key?("sfx.request_id")
      msg = "request contains sfx request id"
    elsif (params.has_key?("__response_type") && params["__response_type"].start_with?("image")) ||
      (params.has_key?("sfx.response_type") && params["sfx.response_type"].start_with?("image"))
      msg = "request is a image-based linking request"
    else
      nil
    end
  end

  def log_resolver_request(msg, params, request)
    Rails.logger.info "#{self.class.name} Referer #{request.referer}"
    Rails.logger.info "#{self.class.name} #{params.to_s}"
    Rails.logger.info "#{self.class.name} #{msg}"
  end
end