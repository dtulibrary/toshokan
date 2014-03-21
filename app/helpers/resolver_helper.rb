# -*- encoding : utf-8 -*-

module ResolverHelper
  include FacetsHelper

  def to_open_url(params)

    if params.has_key?("url_ver") || params.has_key?("sid")

      # convert some fields from Google Scholar format
      if params.has_key?("sid")

        # set journal title
        if params.has_key?("title") && params.has_key?("atitle")
          params["jtitle"] = params["title"]
          params.delete("title")
        elsif params.has_key?("stitle") && params.has_key?("atitle")
          params["jtitle"] = params["stitle"]
          params.delete("stitle")
        end

        # make sure format is set before creating OpenURL
        if params.has_key?("genre") && params["genre"] == "book"
          params["rft_val_fmt"] = "info:ofi/fmt:kev:mtx:journal"
          params["rft.genre"] = "book"
        elsif params.has_key?("atitle")
          params["rft_val_fmt"] = "info:ofi/fmt:kev:mtx:journal"
          params["rft.genre"] = "article"
        end
      end

      # work around for OpenURLs where jtitle is set to title
      if params.has_key?("rft.title") && params.has_key?("rft.atitle")
        params["rft.jtitle"] = params["rft.title"]
        params.delete("rft.title")
      end

      ou = OpenURL::ContextObject.new_from_form_vars(params)

      # handle multiple authors (otherwise lost)
      if params.has_key?("rft.au") || params.has_key?("au") || params.has_key?("rft.aulast") || params.has_key?("aulast")

        # clear authors
        ou.referent.authors.each {|author| ou.referent.remove_author(author) }

        # note params[non-existing-key] returns [], not nil
        if params.has_key?("rft.aulast") || params.has_key?("aulast")
          author = OpenURL::Author.new
          author.aulast = params.has_key?("rft.aulast") ? params["rft.aulast"] : params["aulast"]
          if params.has_key?("rft.aufirst")
            author.aufirst = params["rft.aufirst"]
          elsif params.has_key?("aufirst")
            author.aufirst = params["aufirst"]
          end
          if params.has_key?("rft.auinit")
            author.auinit = params["rft.auinit"]
          elsif params.has_key?("auinit")
            author.auinit = params["auinit"]
          end
          ou.referent.add_author(author)
        end

        if params.has_key?("rft.au") || params.has_key?("au")
          authors = params.has_key?("rft.au") ? params["rft.au"] : params["au"]
          authors = [authors] if authors.is_a? String
          authors.each do |author|
            ou_author = OpenURL::Author.new
            ou_author.au = author
            ou.referent.add_author(ou_author)
          end
        end
      end

      if ou.referent.metadata["genre"].blank? && ou.referent.format == "journal" && !ou.referent.metadata["atitle"].blank?
        ou.referent.metadata["genre"] = "article"
      end

      ou
    else
      Rails.logger.debug "This does not look like an OpenURL: #{params.inspect}"
      nil
    end
  end

  def get_resolver_result(params)

    params.merge!({:qt => '/resolve', :rows => 2, :echoParams => 'all'}).merge!(blacklight_config[:resolver_params])

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
    q = params[:unescaped_q] || ""

    # if any of the facet fields configured in Blacklight is set in the query field,
    # convert it to a facet parameter
    blacklight_config[:facet_fields].keys.each do |facet_field|
      if m = /(#{facet_field}:(\S+))/.match(q)
        new_params = add_facet_params(facet_field, m[2], new_params)
        q.sub!(m[1], "").strip!
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