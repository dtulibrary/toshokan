require 'uri'

# TODO TLNI: Move these classes (They are not Helpers ... But where to?)
module FreeciteHelper
  class FreeciteResponse
    def initialize(values = {})
      @values = values
    end

    def authors
      @values[:authors] || []
    end

    def unabbreviated_names_of_the_first_author
      (authors.first || "").split(/\s+/).select { |word| word.length > 1 }.join(" ") || ""
    end

    def journal_title
      @values[:journal_title] || ""
    end

    def volume
      @values[:volume] || ""
    end

    def pages
      @values[:pages] || ""
    end

    def publisher
      @values[:publisher] || ""
    end

    def title
      @values[:title] || ""
    end

    def year
      @values[:year] || ""
    end
  end

  class FreeciteRequest
    def initialize(freecite_base_url, query)
      @freecite_base_url = freecite_base_url
      @query = query
    end
    attr_reader :freecite_base_url, :query

    def call
      begin
        parse_http_response(perform_get_request)
      rescue Exception => e
        FreeciteResponse.new
      end
    end

    def parse_http_response(http_response)
      json = JSON.parse(http_response)
      FreeciteResponse.new({
        :authors => json["authors"],
        :journal_title => json["journal"],
        :volume => json["volume"],
        :pages => json["pages"],
        :publisher => json["publisher"],
        :year => json["year"],
        :title => json["title"]
      })
    end

    def perform_get_request
      uri = URI(freecite_base_url)
      uri.query = URI.encode_www_form({ "q" => query })

      http_response = Net::HTTP.get_response(uri)

      if not http_response.is_a?(Net::HTTPSuccess)
        raise Exception.new("Freecite - HTTP request failed")
      end

      http_response.body
    end
  end
end
