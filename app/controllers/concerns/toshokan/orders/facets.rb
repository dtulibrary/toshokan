module Toshokan
  module Orders
    module Facets
      def create_facets
        %w(
          user
          user_type
          org_unit
          origin
          status
          duration
          start_year
          start_month
          end_year
          end_month
          supplier
        ).each {|n| self.send("create_#{n}_facet")}
      end

			def create_user_facet
				@facets[:user] = ActiveSupport::OrderedHash.new
				@facet_labels[:user] = {}
				@orders.where('user_id is not null').group('user_id').reorder('count_all desc').limit(20).count.each do |user_id, count|
					user_id = user_id.to_s
					@facets[:user][user_id] = count
					user = User.find user_id
					if user.dtu?
						@facet_labels[:user][user_id] = "#{user} (CWIS: #{user.user_data["dtu"]["matrikel_id"]})"
					else
						@facet_labels[:user][user_id] = user.to_s
					end
				end
      end

      def create_user_type_facet
				@facets[:user_type] = @orders.group('user_type')
																		 .reorder('count_all desc')
																		 .count

      end

      def create_org_unit_facet
				@facets[:org_unit] = @orders.where('org_unit is not null')
																		.group('org_unit')
																		.reorder('count_all desc')
																		.count
      end

      def create_origin_facet
				@facets[:origin] = @orders.group('origin')
																	.reorder('count_all desc')
																	.count
      end

      def create_status_facet
				cases = {
					'initiated'            => 'requested',
					'delivery_requested'   => 'requested',
					'redelivery_requested' => 'requested'
				}.collect {|k,v| "when '#{k}' then '#{v}'"}.join ' '

				@facets[:delivery_status] = @orders.group("case delivery_status #{cases} else delivery_status end")
																					 .reorder('count_all desc')
																					 .count
      end

      def create_duration_facet
        cases = {
          6        => '6h',
          24       => '1d',
          7*24     => '1w',
          4*7*24   => '1m',
          3*4*7*24 => '3m',
        }.collect {|k,v| "when duration_hours <= #{k} then '#{v}'"}.join ' '

        # -- Get non-overlapping intervals
        groups = @orders.where('duration_hours is not null')
                        .group("case #{cases} else '3m+' end")
                        .reorder('count_all desc')
                        .count

        # -- Accumulate overlapping intervals
        accum = {}
        {
          '6h'  => ['6h'],
          '1d'  => ['6h', '1d'],
          '1w'  => ['6h', '1d', '1w'],
          '1m'  => ['6h', '1d', '1w', '1m'],
          '3m'  => ['6h', '1d', '1w', '1m', '3m'],
          '3m+' => ['3m+']
        }.each do |destination, sources|
          accum[destination] = 0
          sources.each do |source|
            accum[destination] += groups[source] if groups[source]
          end
        end

        # -- Reject groups with zero count and sort by count descending
        @facets[:duration] = {}
        accum.reject {|g,count| count == 0}
             .sort   {|a,b| b[1] <=> a[1]}
             .each   {|g,count| @facets[:duration][g] = count}
      end

      def create_start_year_facet
        @facets[:order_start_year] = @orders.group('created_year')
                                            .reorder('created_year desc')
                                            .count
      end

      def create_start_month_facet
        @facets[:order_start_month] = @orders.group('created_month')
                                             .reorder('created_month asc')
                                             .count
        @facets[:order_start_month] = @facets[:order_start_month].sort {|a,b| a[0].to_i <=> b[0].to_i}
      end

      def create_end_year_facet
        @facets[:order_end_year] = @orders.where('delivered_at is not null')
                                          .group('delivered_year')
                                          .reorder('delivered_year desc')
                                          .count
      end

      def create_end_month_facet
        @facets[:order_end_month] = @orders.where('delivered_at is not null')
                                           .group('delivered_month')
                                           .reorder('delivered_month asc')
                                           .count
        @facets[:order_end_month] = @facets[:order_end_month].sort {|a,b| a[0].to_i <=> b[0].to_i}
      end

      def create_supplier_facet
        @facets[:supplier] = @orders.group('supplier')
                                    .reorder('count_all desc')
                                    .count
      end
    end
  end
end
