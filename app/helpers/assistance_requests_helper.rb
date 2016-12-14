module AssistanceRequestsHelper

  # Renders a label and a text field.
  # Add :required => true to make the field required
  def labeled_text_field object_name, field_name, field_label, options = {}
    param_name = "#{object_name}[#{field_name}]"
    if options[:required]
      cssClass = 'required'
      if @assistance_request.errors.messages.has_key? field_name.to_sym
        cssClass += ' error'
      end
      options[:class] += ' ' if options[:class]
      options[:class] = (options[:class] || '') + cssClass
    end
    label_for(param_name, object_name, field_name, field_label, options) +
    text_field_tag(param_name, params[object_name] && params[object_name][field_name], options)
  end

  def label_for param_name, object_name, field_name, field_label, options = {}
    if options[:required]
      cssClass = 'required'
      if @assistance_request.errors.messages.has_key? field_name.to_sym
        cssClass += ' error'
      end
      label_tag(param_name, "#{field_label} <span class=\"required-label\">(<i>required</i>)</span>".html_safe, :class => cssClass)
    else
      label_tag(param_name, "#{field_label} <span class=\"required-label hide\">(<i>required</i>)</span>".html_safe)
    end
  end

  def labeled_text_area object_name, field_name, field_label, options = {}
    param_name = "#{object_name}[#{field_name}]"
    options[:class] = 'required' if options[:required]
    label_for(param_name, object_name, field_name, field_label, options) +
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

  def render_search_tips?
    params[:record_id].blank?
  end

  def search_tips(genre)
    return if params[:record_id]

    if t("toshokan.assistance_requests.search_tips.#{@genre}").is_a?(Array)
      if @genre == :patent
        t("toshokan.assistance_requests.search_tips.#{@genre}")
      else
        t("toshokan.assistance_requests.search_tips.general") +
        t("toshokan.assistance_requests.search_tips.#{@genre}")
      end
    else
      t("toshokan.assistance_requests.search_tips.general")
    end
  end

  def thesis_type_options(assistance_request)
    html = ''
    ['master', 'phd', 'doctoral'].each do |type|
      html += "<option value=\"#{type}\"#{ type == assistance_request.thesis_type ? ' selected="selected"' : '' }>#{t "toshokan.assistance_requests.thesis_types.#{type}"}</option>"
    end
    html.html_safe
  end

  def render_assistance_request_option? document
    can?(:request, :assistance) && (
      # Article subtypes
      (document['format'] == 'article' && ['conference_paper', 'bookchapter'].include?(document['subformat_s'])) ||
      # Book subtypes
      (document['format'] == 'book' && document['subformat_s'].blank?) ||
      # Thesis subtypes
      (document['format'] == 'thesis' && (document['subformat_s'].blank? || ['doctoral', 'phd'].include?(document['subformat_s']))) ||
      # Other
      document['format'] == 'other'
    )
  end

  # Create a link to an assistance request form
  # If we have the doc we just supply the cluster_id
  # If there is no cluster id, we don't have the doc in the index
  # so we parse the doc values to create a pre-filled request form
  def assistance_request_link(document)
    if document['cluster_id_ss'].present?
      new_assistance_request_path(:record_id => document['cluster_id_ss'].first)
    else
      # get the right params for an assistance request
      # wrap the params so they can be parsed by the assistance request form
      genre = determine_assistance_request_genre(document)
      req_params = AssistanceRequest.params_for_doc(document)
      params = Hash[req_params.map{|k,v| ["assistance_request[#{k}]", v]}].merge(:genre => genre)
      new_assistance_request_path(params)
    end
  end

  def determine_assistance_request_genre(document)
    AssistanceRequest.request_genre(document)
  end
end
