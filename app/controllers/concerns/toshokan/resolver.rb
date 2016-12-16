module Toshokan
  module Resolver
    extend ActiveSupport::Concern

    include FacetsHelper
    include Blacklight::UrlHelperBehavior

    def to_open_url(params)
      # work around Reaxys openurls with uppercase sid param
      params["sid"] = params.delete("SID") if params.has_key?("SID")

      if params.has_key?("url_ver") || params.has_key?("sid")

        # openurl 0.1 -> 1.0 preparations
        # note that some can be a mix of the two
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
          if params.has_key?("genre") && ["book", "bookitem", "conference", "proceeding"].include?(params["genre"]) && !params.has_key?('rft_val_fmt')
            params["rft_val_fmt"] = "info:ofi/fmt:kev:mtx:book"
            params["rft.genre"] = params["genre"]
            if(params.has_key?("title"))
              params["rft.btitle"] = params["title"]
              params.delete("title")
            end
          elsif params.has_key?("atitle") && !params["atitle"].blank?
            params["rft_val_fmt"] = "info:ofi/fmt:kev:mtx:journal"
            params["rft.genre"] = "article"
          end
        end

        # work around for OpenURLs where jtitle is set to title
        if params.has_key?("rft.title") && params.has_key?("rft.atitle") && !params["rft.atitle"].blank?
          params["rft.jtitle"] = params["rft.title"]
          params.delete("rft.title")
        end

        # make sure that format is set
        unless params.has_key?("rft_val_fmt")
          if params.has_key?("rft.btitle")
            params["rft_val_fmt"] = "info:ofi/fmt:kev:mtx:book"
          else
            params["rft_val_fmt"] = "info:ofi/fmt:kev:mtx:journal"
          end
        end

        # make sure format is correct set
        unless params["rft_val_fmt"].start_with?("info:ofi/fmt:kev:mtx:")
          params["rft_val_fmt"].prepend("info:ofi/fmt:kev:mtx:")
        end

        ou = OpenURL::ContextObject.new_from_form_vars(params)

        # set identifiers for openurl v. 0.1 input
        if params.has_key?("sid") && ou.referrer.identifiers.nil?
          ou.referrer.add_identifier(params["sid"])
        end

        # set date as year
        if ou.referent.metadata.has_key?("date") && m = /^(\d{4})?+(-?\d{2}){1,2}*$/.match(ou.referent.metadata["date"])
          ou.referent.set_metadata("date", m[1])
        elsif ou.referent.metadata.has_key?("date")
          ou.referent.metadata.delete("date")
        end

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
      # Google scholar sometimes puts the doi in the rft_id field, we catch this and
      # add it to the correct field so it can be used in resolving the search
      if params['rft.doi'].blank? && params['rft_id'].present? && params['rft_id'].any? {|id| id.include?('doi')}
        params['rft.doi'] = params['rft_id'].select {|id| id.include? 'doi' }.first
      end
      params.merge!({:rows => 2, :echoParams => 'all'})
          .merge!(blacklight_config[:resolver_params])
      updated_params = strip_whitespace(params)
      res = blacklight_solr.send_and_receive('resolve', :params => add_inclusive_access_filter(updated_params))
      solr_response = Blacklight::SolrResponse.new(res, updated_params)
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

    # This can be replaced with .transform_values(&:strip)
    # when we have Active Support 4.2.1 or greater
    def strip_whitespace(old_hash)
      new_hash = {}
      old_hash.each do |k,v|
        val = v.is_a?(String) ? v.strip : v
        new_hash[k] = val
      end
      new_hash
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
end
