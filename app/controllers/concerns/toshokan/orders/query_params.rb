module Toshokan
  module Orders
    module QueryParams
      def apply_query_params
        [:q_email, :q_orderid, :q_supplier_order_id].each do |q|
          if params[q] && !params[q].blank?
            value = params[q].strip
            @orders = @orders.where("#{db_field(q)} #{db_op(q)} ?", extract_value(q, value))
          end
        end
      end

      private

      # Translate certain query params to the form used in the model.
      # This can be something like extracting an integer id from a string or similar.
      def extract_value(q, v)
        map = {}

        order_id_prefix = Rails.application.config.orders[:order_id_prefix]

        map[:q_orderid] = -> v do
          # Either match a full DIBS order id like F00001234
          %r{^#{order_id_prefix.downcase}0*(\d+)$}.match(v.downcase).try(:[], 1) ||
          # or a DB id like 1234
          /^(\d+)$/.match(v).try(:[], 1) ||
          # Default to an id that will not match any order.
          0
        end

        map[q].try(:call, v) || "%#{v}%" 
      end

      # Define what type of operator should be used in the SELECT statement for a specific
      # query param.
      def db_op(q)
        map = {
          :q_orderid => '=',
        }

        map[q] || 'LIKE'
      end

      # Define what field should be selected from the database for a specific query param.
      def db_field(q)
        map = {
          :date                => 'date(orders.created_at)',
          :q_email             => 'orders.email',
          :q_orderid           => 'orders.id',
          :q_supplier_order_id => 'orders.supplier_order_id'
        }

        map[q] || q
      end
    end
  end
end
