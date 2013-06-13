require 'httparty'

class CoverImages
  include Configurable

  def self.extract_identifier document
    issns = document['issn_ss'] || []
    isbns = document['isbn_ss'] || []

    result = issns.first || 'XXXXXXXX'

    if result == 'XXXXXXXX'
      isbns.each do |isbn|
        # Always use 13-digit ISBNs (which is the longest one)
        result = isbn if isbn.length > result.length
      end
    end

    result
  end

  def self.url_for id 
    logger.debug "cover_image config: #{config}"
    "#{config.url}/#{config.api_key}/#{id}/native.png"
  end

  def self.get id
    HTTParty.get self.url_for(id)
  end

end
