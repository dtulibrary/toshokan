require 'httparty'

class DocDel
  include Configured

  def self.request_delivery order, callback_url
    supplier_map = {
      :rd => :reprintsdesk,
      :dtu => :dtu_print
    }

    params = {
      :open_url => order.open_url,
      :supplier => supplier_map[order.supplier],
      :email => order.email,
      :callback_url => callback_url
    }

    response = HTTParty.post DocDel.url, :body => params

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
