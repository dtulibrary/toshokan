module RSolr
  class Connection

    alias_method :execute_without_rails_caching_and_retries, :execute

    # @param h Net::HTTP
    # @param request Net::HTTP::Get
    # @param options Hash
    def try_request(h, request, options = {})
      options = {
        :retries => 0,
        :retry_delay => 0.1,
        :retry_on => [500, 502, 503, 504]
      }.merge(options)

      (options[:retries]).downto(0) do |retries_left|

        response = h.request request
        charset = response.type_params["charset"]
        response = {:status => response.code.to_i, :headers => response.to_hash, :body => force_charset(response.body, charset)}
        if (retries_left == 0) || options[:retry_on].exclude?(response[:status])
          return response, options[:retries] - retries_left
        else
          Rails.logger.warn("Solr returned HTTP #{response[:status]} for #{request.method} #{request.path}. Retrying request. #{retries_left} retries left.")
          sleep(options[:retry_delay])
        end
      end

    end


    # Explanation of Caching code:
    #
    # 1. Before making a request FindIt makes a cache key out of the request params
    # 2. FindIt then looks for a cache entry with this key and reads its `last_modified` attribute
    # 3. It adds this `last_modified` attribute as a header on the HTTP request and queries Solr.
    # 4. If Solr returns a HTTP 304 (Not Modified) the cached entry is returned,
    #    otherwise the response body is written to the cache and returned
    def execute client, request_context
      if [:get, :head].exclude? request_context[:method]
        return execute_without_rails_caching_and_retries client, request_context
      end

      bench_start = Time.now

      # Get cache entry from Dalli and use its
      # last_modified attribute to ask Solr if it has been updated
      params = request_context[:params]
      cache_key = params.hash.to_s
      cache_entry = Rails.cache.read(cache_key)
      request_context[:headers] = Hash["If-Modified-Since" => cache_entry[:last_modified]] if cache_entry

      h = http request_context[:uri], request_context[:proxy], request_context[:read_timeout], request_context[:open_timeout]
      request = setup_raw_request request_context
      request.body = request_context[:data] if request_context[:method] == :post and request_context[:data]

      begin
        cache_hit = false

        # execute request
        retry_options = (Rails.application.config.respond_to?(:rsolr) && Rails.application.config.rsolr) || {}
        response, retries = try_request h, request, retry_options

        if 304 == response[:status]
          # read response from cache if code if 304 Not Modified
          cache_hit = true
          response = cache_entry[:response]
        elsif [200,302].include? response[:status]
          # store response in cache if successful
          Rails.cache.write(cache_key, {:last_modified => response[:headers]["last-modified"].first, :etag => response[:headers]["etag"].first, :response => response})
        end

        # log request and statistics in json format
        log_message = {:status => response[:status], :cache => (cache_hit ? :hit : :miss ), :params => params, :time => '%.1f ms' % ((Time.now.to_f - bench_start.to_f) * 1000), :retries => retries}
        Rails.logger.info("RSolr#execute #{log_message.to_json}")

        # Send statistics to Grafana
        time_taken = (Time.now - bench_start) * 1000
        monitor_query_time(time_taken, params["q"], retries, cache_hit)
      # catch the undefined closed? exception -- this is a confirmed ruby bug
      rescue NoMethodError
        $!.message == "undefined method `closed?' for nil:NilClass" ?
          raise(Errno::ECONNREFUSED.new) :
          raise($!)
      end

      response
    end

    def monitor_query_time(time_taken, query, retries, cache_hit)
      if Rails.application.config.try(:monitoring_id) && Rails.application.config.monitoring_id.present?
        query = "blank" unless query.present?
        DtuMonitoring::InfluxWriter.delay(priority: 10).write(
          "solr_response_time",
          { app: Rails.application.config.monitoring_id },
          { value: time_taken, q: query, retries: retries, cache_hit: cache_hit },
          Time.now.to_i
        )
      end
    end

  end

end
