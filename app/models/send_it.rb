require 'httparty'

class SendIt
  include Configured

  def self.send_mail template, params = {}
    begin
      url = "#{SendIt.url}/send/#{template}"
      Rails.logger.info "Sending mail request to SendIt: URL = #{url}, template = #{template}, params = #{params}"
      response = HTTParty.post url, {
        :body => {
          :from => 'noreply@dtic.dtu.dk'
        }.merge(params).to_json, 
        :headers => { 'Content-Type' => 'application/json' }
      }
      unless response.code == 200
        Rails.logger.error "SendIt responded with HTTP #{response.code}"
        raise "Error communicating with SendIt"
      end
    rescue
      Rails.logger.error "Error sending mail: template = #{template}\n#{params}"
      raise
    end
  end

  def self.send_cancellation_mail order, params = {}
    send_mail 'findit_cancellation', {
      :to => order.email,
      :from => Orders.reply_to_email,
      :order => {
        :id => order.id,
        :title => order.document['title_ts'],
        :journal => order.document['journal_title_ts'],
        :author => order.document['author_ts'],
        :amount => order.price,
        :vat => order.vat,
        :currency => order.currency,
        :total => (order.price + order.vat)
      }
    }.merge(params)
  end

end