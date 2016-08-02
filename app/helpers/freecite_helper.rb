require 'uri'
require 'nokogiri'

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
    def initialize(query)
      @query = query
    end

    def query
      @query
    end

    def call
      begin
        parse_http_response(perform_post_request)
      rescue Exception => e
        FreeciteResponse.new
      end
    end

    def parse_http_response(http_response)
      doc = Nokogiri::XML(http_response)
      doc.remove_namespaces!

      FreeciteResponse.new({
        :authors => xpath_list(doc, "/citations/citation[1]/authors/author"),
        :journal_title => xpath(doc, "/citations/citation[1]/journal"),
        :volume => xpath(doc, "/citations/citation[1]/volume"),
        :pages => xpath(doc, "/citations/citation[1]/pages"),
        :publisher => xpath(doc, "/citations/citation[1]/publisher"),
        :year => xpath(doc, "/citations/citation[1]/year"),
        :title => xpath(doc, "/citations/citation[1]/title")
      })
    end

    def xpath(doc, xpath_expr, default_value = "")
      element = doc.xpath(xpath_expr).first
      if element.nil?
        default_value
      else
        element.text
      end
    end

    def xpath_list(doc, xpath_expr, default_value = "")
      elements = (doc.xpath(xpath_expr) || [])
      elements.collect do |element|
        if element.nil?
          default_value
        else
          element.text
        end
      end
    end

    def perform_post_request
      uri = URI(freecite_base_url)

      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"
        http.use_ssl = true
      end

      http_response = http.start do |http|
        request = Net::HTTP::Post.new(uri)

        request["Accept"] = "application/xml, text/xml, */*; q=0.01"

        request.set_form_data('citation' => query)

        http.request(request)
      end

      if http_response.code != "200"
        raise Exception.new("Freecite - HTTP request failed (response code != 200)")
      end

      http_response.body
    end

    def freecite_base_url
      "http://freecite.library.brown.edu/citations/create"
    end
  end
end
