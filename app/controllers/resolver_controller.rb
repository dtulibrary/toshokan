class ResolverController < ApplicationController

  include Toshokan::PerformsSearches
  include Toshokan::Resolver

  rescue_from RSolr::Error::Http do |exception|
    flash[:error] ||= []
    flash[:error] << exception.message
    redirect_to :root
  end

  def index

    # get params from request query string to maintain multiple values with the same key
    openurl_params = CGI::parse(request.query_string)

    # extra url decode in case of double encoding
    openurl_params.each do |key, val|
      if val.length == 1
        openurl_params[key] = URI.unescape(val.first.to_s)
      else
        val.map! {|v| URI.unescape(v.to_s) }
      end
    end
   openurl_params.delete_if{|k,v| k.start_with?("assistance") }

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

        Rails.logger.info "context_object #{context_object.kev}"

        (count, @response, @document) = get_resolver_result(context_object.to_hash)

        case count
        when 0
          # Reference can not be found, create synthesized solr document from OpenURL

          # In case of Pubmed where url metadata are quite sparse try to get more info via Pubmed API
          if openurl_params.has_key?("sid") && openurl_params["sid"] == "Entrez:PubMed" && openurl_params.has_key?("id") && m = openurl_params["id"].match(/pmid:(\d*)/)
            doc = Pubmed.get_solr_document(openurl_params["id"].match(m[1]))
            @document = SolrDocument.create_synthesized_record(doc)
          end

          @document ||= SolrDocument.create_from_openURL(context_object)

          log_resolver_request("Creating synthesized record", doc || openurl_params, request)
          # remove context object params in order to not include in search form hidden fields
          params.slice!(:controller, :action)
          params[:resolve] = true
          render('catalog/show') and return
        when 1
          # One record is found from the reference
          log_resolver_request("Found record #{@document.id}", openurl_params, request)
          catalog_params = {}
          catalog_params[:id] = @document.id
          catalog_params[:assistance_request] = params["assistance_request"] if params.has_key?("assistance_request")
          catalog_params[:assistance_genre] = params["assistance_genre"] if params.has_key?("assistance_genre")
          redirect_to catalog_path catalog_params and return
        else
          # More records are found from the reference
          catalog_params = solr_params_to_blacklight_query(@response['responseHeader']['params'])
          catalog_params[:from_resolver] = true
          catalog_params[:assistance_request] = params["assistance_request"] if params.has_key?("assistance_request")
          catalog_params[:assistance_genre] = params["assistance_genre"] if params.has_key?("assistance_genre")
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
    elsif (params.has_key?("rfr_id") &&
      (params["rfr_id"] == "info:sid/sfxit.com:kbmanager" || params["rfr_id"] == "info:ofi/rfr:db:verde") && params.has_key?("rft.object_id"))
      msg = "request comes from SFX Admin or Verde"
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