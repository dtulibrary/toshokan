class Redmine
  def initialize url, api_key, options = {:timeout => 60}
    @options = options
    @url     = url
    @api_key = api_key
  end

  def create_issue params
    return {'issue' => {'id' => 0}} if Rails.configuration.respond_to?(:enable_creation_of_redmine_issues) && !Rails.configuration.enable_creation_of_redmine_issues

    send_create_request :issues, :issue => params
  end

  def send_get_request path, params = {}
    url = "#{@url}/#{path}.json?#{params.merge({ :key => @api_key }).collect {|k,v| "#{k}=#{URI.encode_www_form_component v}"}.join('&')}"

    response = HTTParty.get url, :timeout => @options[:timeout]

    if response.code == 200
      JSON.parse response.body
    else
      logger.error "Error sending request to redmine:\n  URL: #{url}\n  Response (HTTP #{response.code}):\n  #{response.body.gsub /\n/, "\n  "}"
      nil
    end
  end

  def logger
    Rails.logger
  end

  def send_create_request path, body
    request = body.merge :key => @api_key

    url = "#{@url}/#{path}.json"

    logger.info "Sending create request to redmine at #{@url}:\n#{request.to_json}"

    response = HTTParty.post url, {
      :timeout => @options[:timeout],
      :headers => {
        'Content-Type' => 'application/json'
      },
      :body => request.to_json
    }

    if response.code == 201
      JSON.parse response.body
    else
      logger.error "Error sending request to redmine:\n  URL: #{url}\n  Request:\n  #{request.to_json}\n  Response (HTTP #{response.code}):\n  #{response.body.gsub /\n/, "\n  "}"
      nil
    end
  end
end
