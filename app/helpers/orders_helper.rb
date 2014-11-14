module OrdersHelper

  def render_scan_price user, supplier, currency = :DKK
    format_price(PayIt::Prices.price_with_vat(user, supplier, currency), currency)
  end

  def render_scan_price_tag user, supplier, index = :true, currency = :DKK
    tag = index ? "span" : "div"

    price = format_price(PayIt::Prices.price_with_vat(user, supplier, currency), currency)
    if index
      html = "<#{tag} class=\"price-index\">#{price}</#{tag}>"
    else
      html = "<#{tag} class=\"price\">#{t 'toshokan.orders.price'}: #{price}</#{tag}>"
    end

    discount_type = PayIt::Prices.discount_type user
    if discount_type
      html += "<#{tag} class=\"discount\">(#{t "toshokan.orders.discount_types.#{discount_type}"} applied)</#{tag}>"
    end
    html.html_safe
  end

  def render_formatted_price price, currency = :DKK
    "<span class=\"price-tag\">#{"%s %6.2f" % [currency, price.to_f/100]}</span>".html_safe
  end

  def render_order_steps order_flow
    step = 0
    steps = order_flow.steps.collect do |v|
      step += 1
      "#{step}. #{I18n.t 'toshokan.orders.steps.' + v.to_s}"
    end
    steps[order_flow.current_step_idx] = "<b>#{steps[order_flow.current_step_idx]}</b>"
    "<div class=\"steps\">#{steps.join(' &rarr; ')}</div>".html_safe
  end

  def format_price price, currency = :DKK
    "%s %6.2f" % [currency, price.to_f/100]
    #number_to_currency price.to_f/100, :unit => currency.to_s, :format => '%u %n'
  end

  def render_switch_locale current_locale
    case current_locale
    when 'da'
      "<div class=\"pull-right\">#{link_to t('toshokan.languages.english_version', :locale => :en), new_order_path(:locale => :en)}</div>".html_safe
    when 'en'
      "<div class=\"pull-right\">#{link_to t('toshokan.languages.danish_version', :locale => :da), new_order_path(:locale => :da)}</div>".html_safe
    end
  end

  def render_terms_accepted_label
    label_tag(:terms_accepted, 
      t('toshokan.orders.form.terms_accepted_html', 
        :link => link_to(t('toshokan.orders.terms_of_service'), 
          Rails.application.config.orders[:terms_of_service][current_locale.to_sym], 
          :target => '_blank')), 
      :class => 'terms-accepted')
  end

  def render_order_item order
    if order.assistance_request_id
      render :partial => '/orders/assistance_request_item', :locals => {:order => order}
    else
      render :partial => '/orders/article_item', :locals => {:order => order}
    end
  end

  def should_render_event? event
  end

  def render_order_event_data order, event
    case event.name
    when /.*confirmed/
      t 'toshokan.orders.supplier_order_id', :supplier => t("toshokan.orders.suppliers.#{order.supplier}"), :order_id => order.supplier_order_id
    when 'reordered'
      t 'toshokan.orders.reordered_by', :name => event.data
    when 'payment_authorized'
      t 'toshokan.orders.paid_with_card', :card_no => event.data
    when 'delivery_manual'
      url = "#{LibrarySupport.url}/issues/#{event.data}"
      link_to url, url
    when 'request_manual'
      link_to t('toshokan.orders.view_order'), assistance_request_path(:id => order.assistance_request_id)
    else
      event.data
    end
  end

end
