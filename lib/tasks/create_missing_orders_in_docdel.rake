require 'json'

namespace :docdelsync do
  desc "Create missing orders in docdel"
  task :create_missing => :environment do
    print_usage = lambda do
      STDERR.puts ''
      STDERR.puts 'Example: CALLBACK_URL_TEMPLATE="http://toshokan/en/orders/<uuid>/delivery where <uuid> will be replaced by the uuid of the order.'
    end

    if !ENV['CALLBACK_URL_TEMPLATE']
      STDERR.puts 'ERROR: CALLBACK_URL_TEMPLATE environment not configured.'
      print_usage.call
      exit 1
    elsif !/<uuid>/.match(ENV['CALLBACK_URL_TEMPLATE'])
      STDERR.puts 'ERROR: CALLBACK_URL_TEMPLATE should include a uuid placeholder written as <uuid>.'
      print_usage.call
      exit 1
    end

    Order.where("docdel_order_id IS NULL AND delivery_status = 'initiated' AND supplier <> 'dtu_manual'").each do |order|
      order_json = JSON.pretty_generate(order.serializable_hash)

      puts ""
      puts ""
      puts ""
      puts "The following order might be missing from DocDel:"
      puts order_json
      puts "Create order in DocDel? (y=yes, n=no, q=quit)"

      user_input = STDIN.gets.chomp.upcase

      if user_input == "Y"
        puts "Requesting delivery ..."
        begin
          DocDel.request_delivery order, ENV['CALLBACK_URL_TEMPLATE'].gsub(/<uuid>/, order.uuid), :timecap_base => Time.now.iso8601 if DocDel.enabled?
          puts "Delivery requested (hopefully)."
        rescue Exception => e
          puts "Delivery request failed!"
        end
      end

      if user_input == "Q"
        puts "Quitting ..."
        exit 0
      end
    end
  end
end
