module UserHelper
  def render_user_address user
    if user.address
      lines = user.address.select {|k,v| k.start_with?('line') && !v.blank? }.values.join('<br>')
      lines += "<br>#{user.address['zipcode']} #{user.address['cityname']}"
      lines.html_safe
    end
  end
end
