require 'digest'
require 'httparty'

module PayIt
  
  class Dibs
    include Configured

    def self.md5_key params = {}
      case params[:key_type]
      when :auth
        digest = Digest::MD5.hexdigest "#{Dibs.md5_key1}merchant=#{Dibs.merchant_id}&orderid=#{params[:order_id]}&currency=#{params[:currency]}&amount=#{params[:amount]}"
        Digest::MD5.hexdigest "#{Dibs.md5_key2}#{digest}"
      when :capture
        digest = Digest::MD5.hexdigest "#{Dibs.md5_key1}merchant=#{Dibs.merchant_id}&orderid=#{params[:order_id]}&transact=#{params[:transaction_id]}&amount=#{params[:amount]}"
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
        logger.error "DIBS responded with HTTP #{response.code}:\n#{response.body}"
      rescue
        logger.error "Error capturing payment from DIBS for DIBS order id = #{order.dibs_order_id}."
        raise
      end
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
