# encoding: utf-8
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def has_search_parameters? 
    result = super || !params[:t].blank? || has_advanced_search_parameters?
  end

  def has_advanced_search_parameters? local_params = params || {}
    result = false
    advanced_search_fields.each do |field_name, field|
      result ||= !local_params[field_name.to_sym].blank?
    end
    result
  end

  def snip_abstract args
    render_abstract_snippet args[:document]
  end

  def render_type args
    I18n.t("toshokan.catalog.formats.#{args[:document][args[:field]]}")
  end

  def render_abstract_snippet document
    snippet = (document['abstract_ts'] || ['No abstract']).first
    return snippet.size > 300 ? snippet.slice(0, 300) + '...' : snippet
  end

  def render_journal_info_show args
    render_journal_info_index args, :show
  end

  def render_journal_info_index args, format = :index
    document = args[:document]
    field = args[:field]
    "#{document[field].first} &mdash; #{render_journal_info(document, format)}".html_safe
  end

  def render_journal_info document, format
    info = []
    info << document['pub_date_tis'].first if document['pub_date_tis']
    info << "Volume #{document['journal_vol_ssf'].first}" if document['journal_vol_ssf']
    info << "Part #{document['journal_part_ssf'].first}" if format == :show && document['journal_part_ssf']
    info << "Issue #{document['journal_issue_ssf'].first}" if document['journal_issue_ssf']
    info << "pp. #{document['journal_page_ssf'].first}" if document['journal_page_ssf']
    (info.join ', ').html_safe
  end

  def render_doi_link args
    doi = args[:document][args[:field]].first
    link_to doi, "http://dx.doi.org/#{doi}"
  end

  def render_author_links args
    authors = args[:document][args[:field]]
    authors.collect { |author| link_to author, root_path(:q => author, :search_field => :author) }.join(content_tag(:span, ', ')).html_safe
  end

  def render_shortened_author_links args
    authors = args[:document][args[:field]]
    if authors.length <= 3
      render_author_links args
    else
      authors[0,3].collect { |author| link_to author, root_path(:q => author, :search_field => :author) }.push(I18n.t('toshokan.catalog.shortened_list.et_al')).join(content_tag(:span, ', ')).html_safe
    end
  end

  def render_keyword_links args
    keywords = args[:document][args[:field]]
    keywords.collect { |keyword| link_to keyword, root_path(:q => "\"#{keyword}\"", :search_field => :subject) }.join(', ').html_safe
  end

  def render_affiliations args
    affiliations = args[:document][args[:field]]
    affiliations.collect { |affiliation| content_tag(:span, affiliation)}.join('<br>').html_safe
  end

  def render_advanced_search_link label = 'More options'
    local_params = {}
    advanced_search_fields.each do |field_name, field|
      if params[field_name] && !params[field_name].blank?
        local_params[field_name] = params[field_name]
      end
    end
    link_to label, advanced_path(local_params), :id => 'more_options_toggle'
  end

  def render_journal_rank(document)
    issn = document['issn_ss'].first || nil
    unless issn.nil? || /^x/ =~ issn
      render :partial => 'catalog/journal_rank', :locals => {:url => Rails.application.config.scopus_url % issn}       
    end
  end

  def normalize_year year, forward_delta = 2, current_year = Time.now.year
    if year < 100
      current_century = current_year - (current_year % 100)
      cutoff_year     = current_year + forward_delta
      cutoff_century  = cutoff_year - (cutoff_year % 100)

      if year <= cutoff_year % 100
        year + cutoff_century
      else
        year + cutoff_century - 100
      end
    else
      year
    end
  end

  def empty_if_not_integer year
    Integer(year.strip.sub(/^0*/, '')) rescue ''
  end

  def normalize_year_range range
    b = empty_if_not_integer(range['begin'])
    e = empty_if_not_integer(range['end'])

    b = normalize_year(b) if b.is_an? Integer
    e = normalize_year(e) if e.is_an? Integer

    if b.is_an?(Integer) && e.is_an?(Integer) && b > e
      e = b
    end

    normalized_range = { 'begin' => b.to_s, 'end' => e.to_s }

    if normalized_range != range
      logger.info "Normalized range #{range} to #{normalized_range}"
    end

    normalized_range
  end

end
