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

  def self.extract_identifiers document
    document['issn_ss'] || document['isbn_ss'] || ['XXXXXXXX']
  end

  def self.url_for id 
    config = self.config
    "#{config.url}/#{config.api_key}/#{id}/native.png"
  end

  def self.get id
    HTTParty.get self.url_for(id)
  end

end
