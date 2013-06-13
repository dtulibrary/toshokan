require 'httparty'

class SendIt
  include Configured

  def self.send_mail template, params = {}
    begin
      url = "#{SendIt.url}/send/#{template}"
      logger.info "Sending mail request to SendIt: URL = #{url}, template = #{template}, params = #{params}"
      response = HTTParty.post url, :body => params.to_json, :headers => { 'Content-Type' => 'application/json' }
      unless response.code == 200
        logger.error "SendIt responded with HTTP #{response.code}"
        raise "Error communicating with SendIt"
      end
    rescue
      logger.error "Error sending mail: template = #{template}\n#{params}"
      raise
    end
  end

end
