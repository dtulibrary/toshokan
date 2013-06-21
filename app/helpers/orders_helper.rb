module OrdersHelper
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
end
