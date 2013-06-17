require 'digest'

module DibsHelper
  
  def render_payment_form order, locale
    amount = order.price + order.vat
    locals = {
      :dibs_payment_url => PayIt::Dibs.payment_url,
      :dibs_order_id => order.dibs_order_id,
      :merchant_id => PayIt::Dibs.merchant_id,
      :amount => amount,
      :currency => order.currency,
      :locale => locale,
      :paytype => PayIt::Dibs.paytype,
      :accept_url => order_receipt_url(order.uuid),
      :callback_url => order_receipt_url(order.uuid),
      :md5_key => PayIt::Dibs.md5_key(:key_type => :auth, :order_id => order.dibs_order_id, :amount => amount, :currency => order.currency),
      :test => PayIt::Dibs.test
    }

    render :partial => 'dibs_payment_form', :locals => locals
  end

end
