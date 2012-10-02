require 'httparty'

class CoverImages

  class Configuration
    attr_accessor :url, :api_key
    
  end

  def self.config
    @@config ||= Configuration.new
  end

  def self.configure
    yield self.config
  end

  def self.url_for document
    config = self.config
    id = document['issn_t'] || document['isbn_t'] || ['XXXXXXXX']
    "#{config.url}/#{config.api_key}/#{id.first}/native.png"
  end

end
