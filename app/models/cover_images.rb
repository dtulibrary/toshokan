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
    id = document['issn_t'] || document['isbn_t'] || ['00000000']
    "#{@@config.url}/#{@@config.api_key}/#{id.first}/native.png"
  end

end
