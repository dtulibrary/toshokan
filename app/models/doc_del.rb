require 'httparty'

class DocDel
  include Configured

  def self.show order_id
    response = HTTParty.get "#{DocDel.url}/rest/orders/#{order_id}.json"
    if response.code == 200
      ActiveSupport::JSON.decode response.body
    else
      Rails.logger.error "Error getting DocDel order with id = #{order_id}:\nResponse: HTTP #{response.code}\nResponse body:\n#{response.body}"
    end
  end

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

    response = HTTParty.post "#{DocDel.url}/rest/orders.json", :body => params

    if response.code == 200
      remote_order = ActiveSupport::JSON.decode response.body
      order.docdel_order_id = remote_order['id']
      is_redelivery = order.delivery_status == :reordered
      order.delivery_status = is_redelivery ? :redelivery_requested : :delivery_requested
      order.save!
    else
      Rails.logger.error "Error communicating with DocDel for order #{order.dibs_order_id}:\nResponse: HTTP #{response.code}\nResponse body:\n#{response.body}"
      raise "Error communicating with DocDel"
    end
  end

end
