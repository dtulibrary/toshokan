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

  def render_abstract_with_highlights args
    document ||= args[:document]
    snippets = []
    field_value = (document['abstract_ts'] || ['No abstract']).first
    snippets << truncate(field_value, length: 300, separator:'')
    if document.has_highlight_field?('abstract_ts')
      highlights = document.highlight_field('abstract_ts').map {|hl| hl.html_safe}
      # if the first highlight is ~300 characters then use it as the main abstract value
      snippets[0] = highlights.shift if highlights.first.length > 297
      snippets += highlights
    end

    return render_snippets(snippets)
  end

  def render_snippets(snippets)
    rendered_snippets = []
    snippets.each_with_index do |snippet, index|
      snippet = "...#{snippet}" unless index == 0 || snippet[0..2] == '...'
      snippet << "..." unless snippet[-3..-1] == '...'
      css_classes = ['snippet']
      css_classes << 'supplemental' if index > 0
      rendered_snippets << content_tag(:div, snippet.html_safe, :class => css_classes.join(' '))
    end
    rendered_snippets
  end

  def render_author_links args
    if args[:document]['author_affiliation_ssf']
      render_author_list args[:document]['author_affiliation_ssf'].first, {:author_with_affiliation => true}
    else
      render_author_list args[:document][args[:field]]
    end
  end


  def highlighted_author_list args
    document ||= args[:document]
    field = args[:field]
    all_values = args[:document][args[:field]]
    if document.has_highlight_field?(field)
      highlighted_authors = document.highlight_field(field)
      highlighted_authors.each do |highlighted|
        all_values.map! do |v|
          if v == highlighted.gsub('<em>','').gsub('</em>','')
            highlighted
          else
            v
          end
        end
      end
    end
    all_values
  end

  def render_shortened_author_links args
    render_author_list highlighted_author_list(args), { :max_length => 3, :append => I18n.t('toshokan.catalog.shortened_list.et_al') }
  end

  def render_author_list authors, options = {}
    if options[:author_with_affiliation]
      affiliations = ActiveSupport::JSON.decode(authors)
      list = []
      affiliations.collect do |affiliation|
        if affiliation.has_key?('au')
          sup_tag = affiliations.size > 1 ? content_tag(:sup, affiliations.index(affiliation) + 1) : ''
          list.concat(affiliation['au'].map { |author| content_tag(:span, :class => "author") { render_author_link(author, options[:suppress_link]).safe_concat(sup_tag)}})
        end
      end
    else
      list = authors.map { |author| content_tag(:span, render_author_link(author, options[:suppress_link]), :class => "author") }
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
    if args[:document]['author_affiliation_ssf']
      affiliations = ActiveSupport::JSON.decode(args[:document]['author_affiliation_ssf'].first)
      affiliations.collect do |affiliation|
        sup_tag = affiliations.size > 1 ? content_tag(:sup, affiliations.index(affiliation) + 1) : ''
        content_tag(:span) { content_tag(:span, "#{affiliation['aff']}").safe_concat(sup_tag) }
      end.join('<br>').html_safe
    else
      affiliations = args[:document][args[:field]]
      affiliations.collect { |affiliation| content_tag(:span, affiliation)}.join('<br>').html_safe
    end
  end

end
