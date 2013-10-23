module AssistanceRequestsHelper
  
  def required_text_field object_name, field_name, field_label
    param_name = "#{object_name}[#{field_name}]"
    cssClass = 'required'
    if @assistance_request.errors.messages.has_key? field_name.to_sym
      cssClass += ' error'
    end
    label_tag(param_name, (field_label + ' (<i>required</i>)').html_safe, :class => cssClass) +
    text_field_tag(param_name, params[object_name] && params[object_name][field_name], :class => cssClass)
  end

  def optional_text_field object_name, field_name, field_label
    param_name = "#{object_name}[#{field_name}]"
    label_tag(param_name, field_label) +
    text_field_tag(param_name, params[object_name] && params[object_name][field_name])
  end

  def optional_text_area object_name, field_name, field_label, options = {}
    param_name = "#{object_name}[#{field_name}]"
    label_tag(param_name, field_label) +
    text_area_tag(param_name, params[object_name] && params[object_name][field_name], options)
  end

  def field_names fields, field_prefix = nil
    fields.collect! {|n| field_prefix + n} if field_prefix
    fields
  end

  def section_fields fields, container, field_prefix = nil
    field_names(fields, field_prefix).each do |f|
      value = container.is_a?(Hash) ? container[f] : container.send(f)
      yield t("toshokan.assistance_requests.forms.field_labels.#{f}"), value unless value.blank?
    end
  end

  def render_section_fields fields, container, field_prefix = nil
    html = '<dl>'
    field_names(fields, field_prefix).each do |f|
      value = container.is_a?(Hash) ? container[f] : container.send(f)
      unless value.blank?
        html += %Q{
          <dt>#{t "toshokan.assistance_requests.forms.field_labels.#{f}"}</dt>
          <dd><tt>#{value}</tt></dd>
        }
      end
    end
    (html + '</dl>').html_safe
  end

end
