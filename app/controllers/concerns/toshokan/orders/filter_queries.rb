module Toshokan
  module Orders
    module FilterQueries
      def apply_filter_queries
        %w(
          user
          user_type 
          org_unit 
          origin supplier 
          delivery_status 
          start_year 
          start_month 
          end_year
        ).each {|n| self.send("apply_#{n}_fq")}
      end

      def apply_user_fq
        unless params[:user].blank?
          @orders = @orders.where :user_id => params[:user].first
          @filter_queries[:user] = [params[:user]].flatten
        end 
      end

      def apply_user_type_fq
        unless params[:user_type].blank?
          @orders = @orders.where :user_type => params[:user_type].first
          @filter_queries[:user_type] = [params[:user_type]].flatten
        end 
      end

      def apply_org_unit_fq
        unless params[:org_unit].blank?
          @orders = @orders.where :org_unit => params[:org_unit].first
          @filter_queries[:org_unit] = [params[:org_unit]].flatten
        end 
      end

      def apply_origin_fq
        unless params[:origin].blank?
          @orders = @orders.where :origin => params[:origin].first
          @filter_queries[:origin] = [params[:origin]].flatten
        end 
      end

      def apply_supplier_fq
        unless params[:supplier].blank?
          @orders = @orders.where :supplier => params[:supplier].first
          @filter_queries[:supplier] = [params[:supplier]].flatten
        end 
      end

      def apply_delivery_status_fq
        unless params[:delivery_status].blank?
          if params[:delivery_status].first == 'requested'
            @orders = @orders.where :delivery_status => ['initiated', 'requested', 'delivery_requested', 'redelivery_requested']
          else
            @orders = @orders.where :delivery_status => params[:delivery_status].first
          end
          @filter_queries[:delivery_status] = [params[:delivery_status]].flatten
        end 
      end

      def apply_start_year_fq
        unless params[:order_start_year].blank?
          @orders = @orders.where :created_year => params[:order_start_year].first
          @filter_queries[:order_start_year] = [params[:order_start_year]].flatten
        end 
      end

      def apply_start_month_fq
        unless params[:order_start_month].blank?
          @orders = @orders.where :created_month => params[:order_start_month].first
          @filter_queries[:order_start_month] = [params[:order_start_month]].flatten
        end 
      end

      def apply_end_year_fq
        unless params[:order_end_year].blank?
          @orders = @orders.where :delivered_year => params[:order_end_year].first
          @filter_queries[:order_end_year] = [params[:order_end_year]].flatten
        end 
      end

      def apply_duration_fq
        unless params[:duration].blank?
          duration = params[:duration].last
          expr = {
            '6h'  => '<= 6',
            '1d'  => '<= 24',
            '1w'  => "<= #{7*24}",
            '1m'  => "<= #{4*7*24}",
            '3m'  => "<= #{3*4*7*24}",
            '3m+' => "> #{3*4*7*24}",
          }

          @orders = @orders.where "duration_hours #{expr[duration]}"
          @filter_queries[:duration] = [duration].flatten
        end
      end
    end
  end
end
