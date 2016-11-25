require 'fileutils'

task :default => [:spec, :cucumber]

if Rails.env == "test"
  WebMock.disable_net_connect!(allow_localhost: true)
end

namespace :orders do
  task :synchronize_with_redmine => :environment do
    latest_redmine_synchronization = RedmineSynchronization.order(:latest_issue_update_time => :desc).first || Struct.new(:latest_issue_update_time).new(DateTime.new)
    LibrarySupport.new.synchronize_order_events_from_redmine(latest_redmine_synchronization.latest_issue_update_time)
  end

  task :retrofit_org_units => :environment do
    if ENV['DTUBASE_URL']
      counter = {
        :dtu_primary_org_unit => 0,
        :dtu_riyosha_org_unit => 0,
        :dtu_no_org_unit      => 0,
        :non_dtu              => 0,
        :total                => 0
      }
      orders = Order.where('user_id is not null').where(:org_unit => nil)
      primary_org_units = {}
      orders.each do |order|
        if order.user.dtu?
          unless primary_org_units.has_key? order.user.identifier
            primary_org_units[order.user.identifier] = fetch_account(order.user.user_data["dtu"]["matrikel_id"], ENV['DTUBASE_URL'])
          end
          org_unit_id = primary_org_units[order.user.identifier]
          if org_unit_id
            counter[:dtu_primary_org_unit] += 1
          else
            org_unit_id = order.user.user_data["dtu"]["org_units"].first
            counter[:dtu_riyosha_org_unit] += 1 if org_unit_id
          end
          if org_unit_id
            order.org_unit = org_unit_id
            order.save!
          else
            counter[:dtu_no_org_unit] += 1
          end
          puts "Processed #{counter[:total]} orders" if counter[:total] % 50 == 0
        else
          counter[:non_dtu] += 1
        end
        counter[:total] += 1
      end
      puts %{
        Orders processed:
          DTU with primary org unit: #{counter[:dtu_primary_org_unit]}
          DTU with riyosha org unit: #{counter[:dtu_riyosha_org_unit]}
          DTU without org unit:      #{counter[:dtu_no_org_unit]}
          Non-DTU:                   #{counter[:non_dtu]}
          Total:                     #{counter[:total]}
      }
    else
      puts "Missing argument: DTUBASE_URL"
    end
  end

  task :fix_delivery_status => :environment do
    Order.where(:delivery_status => :requested).each do |order|
      order.delivery_status = :delivery_requested
      order.save!
    end
  end

  task :create_orders_for_existing_assistance_requests => :environment do
    select = AssistanceRequest.where('id not in (select assistance_request_id from orders where assistance_request_id is not null)')
    puts "Migrating #{select.count} assistance requests..."
    select.find_each do |r| 
      order = Order.new
      order.user = r.user
      order.assistance_request_id = r.id
      order.created_at = r.created_at
      order_updated_at = r.updated_at
      order.supplier = :dtu_manual
      order.supplier_order_id = r.library_support_issue
      order.price = 0 
      order.vat = 0 
      order.currency = :DKK
      order.email = r.user.email
      order.uuid = UUIDTools::UUID.timestamp_create.to_s
      order.open_url = r.openurl.kev
      order.org_unit = r.user.user_data["dtu"]["org_units"].first if r.user.dtu?
      order.delivery_status = :initiated
      order.order_events << OrderEvent.new(:name => 'delivery_manual', :data => r.library_support_issue)
      order.save!
    end 
    puts "Done."
  end

  task :retrofit_user_type => :environment do
    select = Order.where(:user_type => nil)
    puts "Retrofitting user type on #{select.count} orders..."
    select.find_each do |order|
      if order.user.blank?
        order.user_type = 'anonymous'
      else
        order.user_type = order.user.type
      end 
      order.save!
    end 
    puts "Done."
  end 

  task :retrofit_origin => :environment do
    select = Order.where(:origin => nil)
    puts "Retrofitting origin on #{select.count} orders..."
    select.find_each do |order|
      order.origin = order.assistance_request_id.blank? ? 'scan_request' : 'assistance_request'
      order.save!
    end 
    puts "Done."
  end

  task :retrofit_year_and_month => :environment do
    select = Order.where(:created_year => nil)
    puts "Retrofitting year and month on #{select.count} orders..."
    select.find_each do |order|
      order.created_year  = order.created_at.year.to_s
      order.created_month = order.created_at.month.to_s
      unless order.delivered_at.blank?
        order.delivered_year  = order.delivered_at.year.to_s
        order.delivered_month = order.delivered_at.month.to_s
      end 
      order.save!
    end 
    puts "Done."
  end
end

namespace :assistance_requests do
  task :retrofit_auto_cancel => :environment do
    select = AssistanceRequest.where(:auto_cancel => 'never')
    puts "Retrofitting auto cancel on #{select.count} assistance requests..."
    select.find_each do |r|
      r.auto_cancel = nil
      r.save!
    end
    puts "Done."
  end
end

def fetch_account matrikel_id, url
  url += "&XPathExpression=#{URI.encode_www_form_component "/account[@matrikel_id = #{matrikel_id}]"}"
  response = HTTParty.get url
  if response.code == 200
    account_md = /<account [^>]*primary_profile_id="(.*?)"/.match response.body
    if account_md
      profile_md = /<profile_\S+ ([^>]*fk_profile_id="#{account_md[1]}".*?)>/.match response.body
      if profile_md
        org_unit_md = /fk_orgunit_id="(.*?)"/.match profile_md[1]
        if org_unit_md
          org_unit_md[1]
        end
      end
    end
  else
    puts "Error fetching URL: #{url}"
  end
end
