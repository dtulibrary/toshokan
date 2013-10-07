require 'httparty'

class DocDel
  include Configured

  def self.request_delivery order, callback_url, options = {}
    supplier_map = {
      :rd => :reprintsdesk,
      :dtu => :local_scan
    }

    params = {
      :dibs_order_id => order.dibs_order_id,
      :open_url => order.open_url,
      :supplier => supplier_map[order.supplier],
      :email => order.email,
      :callback_url => callback_url
    }

    params[:user_id] = order.user.identifier if order.user
    params[:timecap_base] = options[:timecap_base] || Time.now.iso8601

    Rails.logger.info "Sending order to DocDel: URL = #{DocDel.url}, params = #{params}"

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
