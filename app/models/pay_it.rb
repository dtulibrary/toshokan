require 'digest'
require 'httparty'

module PayIt
  
  class Dibs
    include Configured

    def self.currency_code currency
      { :DKK => 208 }[currency]
    end

    def self.md5_key params = {}
      case params[:key_type]
      when :auth
        digest = Digest::MD5.hexdigest "#{Dibs.md5_key1}merchant=#{Dibs.merchant_id}&orderid=#{params[:order_id]}&currency=#{currency_code params[:currency]}&amount=#{params[:amount]}"
        Digest::MD5.hexdigest "#{Dibs.md5_key2}#{digest}"
      when :capture
        digest = Digest::MD5.hexdigest "#{Dibs.md5_key1}merchant=#{Dibs.merchant_id}&orderid=#{params[:order_id]}&transact=#{params[:transaction_id]}&amount=#{params[:amount]}"
        Digest::MD5.hexdigest "#{Dibs.md5_key2}#{digest}"
      when :auth_key
        digest = Digest::MD5.hexdigest "#{Dibs.md5_key1}transact=#{params[:transaction_id]}&amount=#{params[:amount]}&currency=#{currency_code params[:currency]}"
        Digest::MD5.hexdigest "#{Dibs.md5_key2}#{digest}"
      end
    end

    def self.capture order
      params = {
        :merchant => Dibs.merchant_id,
        :orderid => order.dibs_order_id,
        :transact => order.dibs_transaction_id,
        :amount => (order.price + order.vat),
        :md5key => md5_key({
          :key_type => :capture, 
          :order_id => order.dibs_order_id, 
          :transaction_id => order.dibs_transaction_id, 
          :amount => (order.price + order.vat)
        })
      }

      logger.info "Capturing payment from DIBS: params = #{params}" 
      begin
        response = HTTParty.post Dibs.capture_url, :body => params
        logger.error "DIBS responded with HTTP #{response.code}:\n#{response.body}" unless response.code == 200
      rescue
        logger.error "Error capturing payment from DIBS for DIBS order id = #{order.dibs_order_id}."
        raise
      end
    end

    def self.authentic? params = {}
      md5_params = {
        :key_type => :auth_key,
        :transaction_id => params[:transact],
        :currency => params[:currency],
        :amount => params[:amount]
      }
      md5_key = self.md5_key md5_params 
      logger.debug "DIBS authkey = #{params[:authkey]}, calculated authkey = #{md5_key}. Based on params #{md5_params}"
      md5_key == params[:authkey]
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
