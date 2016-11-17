FactoryGirl.define do
  factory :order_event do
  end

  factory :order do
    supplier "tib"
    price 0
    vat 0
    currency "DKK"
    email "nomail@localhost"
    open_url "-"
  end
end
