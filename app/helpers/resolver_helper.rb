# -*- encoding : utf-8 -*-

module ResolverHelper
  include FacetsHelper

  def to_open_url(params)

    if params.has_key?("url_ver") || params.has_key?("sid")

      # convert some fields from Google Scholar format
      if params.has_key?("sid") && (params["sid"] == "google" || params["sid"] == "pure.atira.dk:pure")

        # set journal title
        if params.has_key?("title") && params.has_key?("atitle")
          params["jtitle"] = params["title"]
          params.delete("title")
        end
      end

      OpenURL::ContextObject.new_from_form_vars(params)
    else
      Rails.logger.debug "This does not look like an OpenURL: #{params.inspect}"
      nil
    end
  end

  def get_resolver_result(params)
    params.merge!({:qt => '/resolve', :rows => 2, :echoParams => 'all'})

    res = blacklight_solr.send_and_receive(blacklight_config.solr_path, :params => add_inclusive_access_filter(params))
    solr_response = Blacklight::SolrResponse.new(force_to_utf8(res), params)
    count = 0
    unless solr_response.docs.empty?
      document = SolrDocument.new(solr_response.docs.first, solr_response)

      count = solr_response['response']['numFound']
      if count == 2
        # check whether its actually the same record with different access rights
        # note this assumes two access rights levels and shared id
        second_document = SolrDocument.new(solr_response.docs[1], solr_response)
        if document.id == second_document.id
          count = 1
        end
      end
    end
    [count, solr_response, document]
  end

  def solr_params_to_blacklight_query(params)

    new_params = {}
    q = params[:q] || ""

    # if any of the facet fields configured in Blacklight is set in the query field,
    # convert it to a facet parameter
    blacklight_config[:facet_fields].keys.each do |facet_field|
      if m = /(#{facet_field}:(\S+))/.match(q)
        new_params = add_facet_params(facet_field, m[2], new_params)
        q = q.sub(m[1], "").strip!
      end
    end

    # create facets from filter queries
    if params[:fq]
      fq_list = []
      fq_list << params[:fq]
      fq_list.flatten!
      fq_list.each do |fq|
        if m = /(\w+):(.+)/.match(fq)
          new_params = add_facet_params(m[1], m[2], new_params) if blacklight_config[:facet_fields].has_key?(m[1])
        end
      end
    end

    new_params[:q] = q
    new_params
  end

end