module RSolr
  class Connection
    alias_method :execute_without_rails_caching, :execute

    def execute client, request_context
      if not [:get, :head].include? request_context[:method]
        return execute_without_rails_caching client, request_context
      end

      bench_start = Time.now

      # Add cache header to request params
      params = request_context[:params]
      cache_key = params.hash.to_s
      cache_header = Rails.cache.exist?(cache_key)? Hash["If-None-Match" => Rails.cache.read(cache_key)[:etag]] : {}
      request_context[:headers] = cache_header

      h = http request_context[:uri], request_context[:proxy], request_context[:read_timeout], request_context[:open_timeout]
      request = setup_raw_request request_context
      request.body = request_context[:data] if request_context[:method] == :post and request_context[:data]
      begin
        cache_hit = false
        # execute request
        response = h.request request
        charset = response.type_params["charset"]
        response = {:status => response.code.to_i, :headers => response.to_hash, :body => force_charset(response.body, charset)}

        if     304 == response[:status]
          # read response from cache if code if 304 Not Modified
          cache_hit = true
          response = Rails.cache.read(cache_key)[:response]
        elsif [200,302].include? response[:status]
          # store response in cache if successful
          Rails.cache.write(cache_key, {:etag => response[:headers]["etag"].first, :response => response})
        end

        # log request and statistics in json format
        log_message = {:status => response[:status], :cache => (cache_hit ? :hit : :miss ), :params => params, :time => '%.1f ms' % ((Time.now.to_f - bench_start.to_f)*1000)}
        Rails.logger.info("RSolr#execute #{log_message.to_json}")

        # TODO: send statistics to ganglia

      # catch the undefined closed? exception -- this is a confirmed ruby bug
      rescue NoMethodError
        $!.message == "undefined method `closed?' for nil:NilClass" ?
          raise(Errno::ECONNREFUSED.new) :
          raise($!)
      end

      response
    end


  end

end
