module DocumentHelper

  def render_type args
    I18n.t("toshokan.catalog.formats.#{args[:document][args[:field]]}")
  end

  def render_subtype args
    I18n.t("toshokan.catalog.subformats.#{args[:document][args[:field]]}")
  end

  # needed for synthesized records via resolver
  def render_link_rel_alternates(document=@document, options = {})
    params[:resolve].blank? ? super : ""
  end

  def snip_abstract args
    render_abstract_snippet args[:document]
  end

  def render_abstract_snippet document
    snippet = (document['abstract_ts'] || ['No abstract']).first
    return snippet.size > 300 ? snippet.slice(0, 300) + '...' : snippet
  end

  def associations(document, role)
    return [] if document['affiliation_associations_json'].blank?
    ActiveSupport::JSON.decode(document['affiliation_associations_json'])[role]
  end

  def render_author_links args
    document = args[:document]
    render_author_list(document[args[:field]], associations(document, "author"))
  end

  def render_editor_links args
    document = args[:document]
    render_author_list(document[args[:field]], associations(document, "editor"))
  end

  def render_shortened_author_links args
    document = args[:document]
    render_author_list(document[args[:field]], nil, {
      :max_length => 3, 
      :append     => I18n.t('toshokan.catalog.shortened_list.et_al')
    })
  end

  def render_author author, options = {}
    extra_content = options[:extra_content] || ''
    "<span class=\"author\">#{render_author_link(author, options[:suppress_link])}#{extra_content}</span>"
  end

  def render_author_list authors, associations, options = {}
    if associations.nil?
      list = authors.map { |author| render_author(author, options) }
    else
      list = authors.each_with_index.map do |author, i|
        options[:extra_content] = "<sup>#{associations[i]+1}</sup>" unless associations[i].nil?
        render_author(author, options)
      end
    end

    case
      when !options[:max_length] && options[:append]
        list << options[:append]
      when options[:max_length] && list.size > options[:max_length]
        list = list[0, options[:max_length]]
        list << options[:append] if options[:append]
    end

    list.join(options[:separator] || content_tag(:span, '; ')).html_safe
  end

  def render_author_link author, suppress_link = false
    link_to_unless( suppress_link, author,
                    set_limit_params_and_redirect(:author, author),
                    { :title => I18n.t('toshokan.catalog.find_by_author', :author => author), :data => { :toggle => 'tooltip' } })
  end

  def render_keyword_links args
    keywords = args[:document][args[:field]]
    keywords.collect { |keyword| link_to keyword, set_limit_params_and_redirect(:subject, keyword), { :title => I18n.t('toshokan.catalog.find_about_subject', :subject => keyword), :data => { :toggle => 'tooltip' } } }.join(', ').html_safe
  end

  def render_affiliations args
    args[:document][args[:field]].each_with_index.map {|aff, i| "<span class=\"affiliation\"><sup>#{i+1}</sup> #{aff}</span>" }.join('<hr style="margin: 0.25em 0">').html_safe
  end

  def render_iso_language(args)
    args[:document][args[:field]].map {|iso_lang| I18n.t("toshokan.iso_languages.#{iso_lang}", default: iso_lang)}
                                 .join('<br>')
                                 .html_safe
  end
end
