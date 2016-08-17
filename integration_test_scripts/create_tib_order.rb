def create_dummy_order
  uuid = SecureRandom.uuid

  puts "Creating order ..."
  order = Order.new({"uuid"=>uuid, "supplier"=>:tib, "price"=>0, "vat"=>0, "currency"=>:DKK, "email"=>"tlni@dtu.dk", "mobile"=>nil, "customer_ref"=>nil, "dibs_transaction_id"=>nil, "payment_status"=>nil, "delivery_status"=>:initiated, "payed_at"=>nil, "delivered_at"=>nil, "user_id"=>1, "open_url"=>"url_ver=Z39.88-2004&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&ctx_ver=Z39.88-2004&ctx_tim=2016-08-11T07%3A19%3A37%2B00%3A00&ctx_id=&ctx_enc=info%3Aofi%2Fenc%3AUTF-8&rft.genre=article&rft.atitle=Neuartige+Beschichtungssysteme+f%C3%BCr+den+Stahlbau%3A+Laboratoriumsuntersuchungen+und+Freibewitterung&rft.au=Steinbeck%2C+Gregor&rft.jtitle=Farbe+Und+Lack&rft.volume=105&rft.issue=2&rft.spage=107&rft.epage=129&rft.date=1999&rft.issn=00147699&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft_id=urn%3Aissn%3A00147699&rft_dat=%7B%22id%22%3A%22251614766%22%7D&rfr_id=info%3Asid%2Ffindit.dtu.dk", "masked_card_number"=>nil, "supplier_order_id"=>nil, "docdel_order_id"=>nil, "org_unit"=>"Myndig", "assistance_request_id"=>nil, "user_type"=>"dtu_staff", "origin"=>"scan_request", "created_year"=>2016, "created_month"=>8, "delivered_year"=>nil, "delivered_month"=>nil, "duration_hours"=>nil})
  order.order_events << OrderEvent.new(:name => :delivery_requested)
  order.delivery_status = :initiated
  order.save!
  puts "Order created (id:#{order.id} uuid:#{order.uuid})!"

  url = "http://findit:3000/en/orders/#{order.uuid}/delivery"

  puts "Requesting delivery of document (url:#{url}) ..."
  DocDel.request_delivery order, url, :timecap_base => Time.now.iso8601 if DocDel.enabled?
  puts "Delivery requested!"
end

create_dummy_order
