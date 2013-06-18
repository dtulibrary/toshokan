require 'digest'
require 'httparty'

module PayIt
  
  class Dibs
    include Configured

    def self.currency_code currency
      { :DKK => 208 }[currency]
    end

    # Calculate a DIBS MD5 key for use in various security checks.
    # It expects an ordered hash with the keys named and ordered
    # as the DIBS documentation prescribes it.
    def self.md5_key params = {}
      params_string = params.to_a.collect {|a,b| "#{a}=#{b}"}.join '&'
      Rails.logger.debug "Calculating MD5 of #{params_string}"
      Digest::MD5.hexdigest(Dibs.md5_key2 + Digest::MD5.hexdigest(Dibs.md5_key1 + params_string))
    end

    def self.capture order
      params = {
        :merchant => Dibs.merchant_id,
        :orderid => order.dibs_order_id,
        :transact => order.dibs_transaction_id,
        :amount => (order.price + order.vat),
        :md5key => md5_key({
          :merchant => Dibs.merchant_id,
          :orderid => order.dibs_order_id, 
          :transact => order.dibs_transaction_id, 
          :amount => (order.price + order.vat)
        })
      }

      Rails.logger.info "Capturing payment from DIBS: params = #{params}" 
      begin
        response = HTTParty.post Dibs.capture_url, :body => params
        if response.code == 200
          order.order_events << OrderEvent.new(:name => 'payment_captured')
          order.save!
        else
          Rails.logger.error "DIBS responded with HTTP #{response.code}:\n#{response.body}"
        end
      rescue
        Rails.logger.error "Error capturing payment from DIBS for DIBS order id = #{order.dibs_order_id}."
        raise
      end
    end

    def self.cancel order
      params = {
        :merchant => Dibs.merchant_id,
        :transact => order.dibs_transaction_id,
        :textreply => 'yes',
        :md5key => md5_key({
          :merchant => Dibs.merchant_id,
          :orderid => order.dibs_order_id,
          :transact => order.dibs_transaction_id
        })
      }

      begin
        Rails.logger.info "Cancelling order with order id = #{order.dibs_order_id} in DIBS."
        response = HTTParty.post Dibs.cancel_url, :body => params
        if response.code == 200
          order.order_events << OrderEvent.new(:name => 'payment_cancelled')
          order.save!
        else
          Rails.logger.error "DIBS responded with HTTP #{response.code}:\n#{response.body}"
        end
      rescue
        Rails.logger.error "Error capturing payment from DIBS for DIBS order id = #{order.dibs_order_id}."
        raise
      end
    end

    def self.authentic? params = {}
      params[:authkey] == md5_key({
        :transact => params[:transact],
        :amount => params[:amount],
        :currency => currency_code(params[:currency])
      })
    end

    def self.status_codes
      {
         '0' => :transaction_inserted,
         '1' => :declined,
         '2' => :authorization_approved,
         '3' => :capture_sent_to_acquirer,
         '4' => :capture_declined_by_acquirer,
         '5' => :capture_completed,
         '6' => :authorization_deleted,
         '7' => :capture_balanced,
         '8' => :partially_refunded_and_balanced,
         '9' => :refund_sent_to_acquirer,
        '10' => :refund_declined,
        '11' => :refund_completed,
        '12' => :capture_pending,
        '13' => :ticket_transaction,
        '14' => :deleted_ticket_transaction,
        '15' => :refund_pending,
        '16' => :waiting_for_shop_approval,
        '17' => :declined_by_dibs,
        '18' => :multicap_transaction_open,
        '19' => :multicap_transaction_closed
      }
    end

    def self.status_code code
      status_codes[code.to_s]
    end
  end

  # Class for retrieving prices and calculating VAT
  # NOTE: All amounts are assumed in cents
  class Prices

    def self.price_matrix
      {   
        :dtu_staff => {
          :rd => {
            :DKK => 0
          },  
          :dtu => {
            :DKK => 0
          }   
        },  
        :dtu_student => {
          :rd => { 
            :DKK => 10000 
          },  
          :dtu => {
            :DKK => 0
          }   
        },  
        :public => {
          :rd => {
            :DKK => 25000
          },  
          :dtu => {
            :DKK => 25000
          }   
        }   
      }   
    end 

    def self.prices user
      price_matrix[user.type]
    end 

    def self.price user, supplier, currency = :DKK
      price_matrix[user.type] ? price_matrix[user.type][supplier][currency] : price_matrix[:public][supplier][currency]
    end 

    def self.price_with_vat user, supplier, currency = :DKK
      amount = self.price user, supplier, currency
      amount + self.vat(amount)
    end 
    
    def self.vat amount
      (0.25 * amount).floor
    end

    def self.discount_type_matrix
      {   
        :dtu_staff => :dtu_staff_discount,
        :dtu_student => :dtu_student_discount,
      }
    end

    def self.discount_type user
      discount_type_matrix[user.type]
    end

  end
end
