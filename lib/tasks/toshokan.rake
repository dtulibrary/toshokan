require 'fileutils'

task :default => [:spec, :cucumber]

if Rails.env == "test"
  WebMock.disable_net_connect!(allow_localhost: true)
end

namespace :orders do
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
