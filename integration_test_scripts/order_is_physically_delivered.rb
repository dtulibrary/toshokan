def order_is_delivered(order_number)
  puts "Using order number: #{order_number}!"

  if Order.any? { |o| o.supplier_order_id.eql?(order_number) && o.order_events.any? { |e| "physical_delivery_done".eql?(e.name) } }
    puts "Success! Order is physically delivered!"
    exit 0
  end

  puts "Failure! Order is NOT physically delivered!"
  exit 2
end

if ARGV.length < 1
  puts "Insufficient parameters passed."
  puts "Usage: #{$0} <supplier_order_number>"
  exit 2
end

order_is_delivered(ARGV[0].chomp)
