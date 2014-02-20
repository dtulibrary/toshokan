require 'fileutils'

task :default => [:spec, :cucumber] 

namespace :orders do
  task :retrofit_org_units => :environment do
    orders = Order.where('user_id is not null').where(:org_unit => nil)
    orders.each do |order|
      if order.user.dtu?
        order.org_unit = order.user.user_data["dtu"]["org_units"].first
        order.save!
      end
    end
  end
end

