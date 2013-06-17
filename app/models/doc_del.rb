require 'httparty'

class DocDel
  include Configured

  def self.request_delivery order, callback_url
    encoded_open_url = URI.encode_www_form_component order.open_url
    encoded_email = URI.encode_www_form_component order.email
    encoded_callback_url = URI.encode_www_form_component callback_url

    supplier_map = {
      :rd => :reprintsdesk,
      :dtu => :dtu_print
    }

    request_url = DocDel.url + "?supplier=#{supplier_map[order.supplier]}&email=#{encoded_email}&callback_url=#{encoded_callback_url}&open_url=#{encoded_open_url}"
    
    Rails.logger.info "Requesting document delivery with DocDel: url = #{request_url}"
    response = HTTParty.get request_url

    if response.code == 200
      # Update order status
      order.delivery_status = :requested
      order.save!
    else
      Rails.logger.error "Error communicating with DocDel:\nRequest: #{request_url}\nResponse: HTTP #{response.code}\n#{response.body}"
      raise "Error communicating with DocDel"
    end
  end

end
