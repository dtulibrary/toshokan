# encoding: utf-8
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def has_search_parameters? 
    result = super || !params[:t].blank? || !params[:l].blank?
  end

  def add_access_filter solr_parameters = {}, user_parameters = {}
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << 'access_ss:dtu' if can? :search, :dtu
    solr_parameters[:fq] << 'access_ss:dtupub' if can? :search, :public
    solr_parameters
  end

  def journal_document_for_issns(issns)
    response = get_solr_response_for_field_values("issn_ss", issns, add_access_filter({:fq => ['format:journal'], :rows => 1})).first
    documents = response[:response][:docs]
    documents.first unless documents.empty?
  end

  def journal_id_for_issns(issns)
    document = journal_document_for_issns(issns)
    document[:cluster_id_ss] if document
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
    document = args[:document]
    field = args[:field]
    has_toc  = document[:toc_key_s] && document[:issn_ss]
    has_journal = document[:toc_key_s] && document[:toc_key_journal_exists] && document[:issn_ss]
    (link_to_if(has_journal && show_feature?(:toc),
        document[field].first,
        catalog_journal_path(:issn => document[:issn_ss], :key => document[:toc_key_s], :ignore_search => '✓'),
        { :title => I18n.t('toshokan.catalog.toc.open_table_of_contents'), :data => { :toggle => 'tooltip' } }) +
      ' — ' +
      link_to_toc_query_if(has_toc && !limit_in_params?(:toc), render_journal_info(document, :show), document[:toc_key_s], document[:journal_title_ts].first) +
      render_journal_page_info(document, :show)).html_safe
  end

  def render_journal_info_index args, format = :index
    document = args[:document]
    field = args[:field]
    has_toc  = document[:toc_key_s] && document[:issn_ss]
    (link_to_if(false && has_toc && show_feature?(:toc),  # disabled until we have journal records for all toc-issns
        document[field].first,
        catalog_journal_path(:issn => document[:issn_ss], :key => document[:toc_key_s], :ignore_search => '✓'),
        { :title => I18n.t('toshokan.catalog.toc.open_table_of_contents'), :data => { :toggle => 'tooltip' } }) +
      ' — ' +
      link_to_toc_query_if(has_toc && !limit_in_params?(:toc), render_journal_info(document, format), document[:toc_key_s], document[:journal_title_ts].first) +
      render_journal_page_info(document, format)).html_safe
  end

  def render_journal_info document, format
    render_journal_info_from_parts(
      document['pub_date_tis']      && document['pub_date_tis'].first,
      document['journal_vol_ssf']   && document['journal_vol_ssf'].first,
      document['journal_issue_ssf'] && document['journal_issue_ssf'].first,
      document['journal_part_ssf']  && document['journal_part_ssf'].first)
  end

  def render_journal_info_from_parts year, vol, issue, part
    info = []
    info << year if year
    info << "#{I18n.t('toshokan.catalog.toc.volume')} #{vol}" if vol
    info << "#{I18n.t('toshokan.catalog.toc.issue')} #{issue}" if issue
    info << part if part
    (info.join ', ').html_safe
  end

  def render_journal_page_info document, format
    ", #{I18n.t('toshokan.catalog.toc.page')} #{document['journal_page_ssf'].first}" if document['journal_page_ssf']
  end

  def render_doi_link args
    doi = args[:document][args[:field]].first
    link_to doi, "http://dx.doi.org/#{doi}"
  end

  def render_author_links args
    render_author_list args[:document][args[:field]]
  end

  def render_shortened_author_links args
    render_author_list args[:document][args[:field]], { :max_length => 3, :append => I18n.t('toshokan.catalog.shortened_list.et_al') }
  end

  def render_author_list authors, options = {}
    list = authors.map { |author| render_author_link author, options[:suppress_link] }

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
    affiliations = args[:document][args[:field]]
    affiliations.collect { |affiliation| content_tag(:span, affiliation)}.join('<br>').html_safe
  end

  def render_journal_rank(document)
    issn = document['issn_ss'].first || nil
    unless issn.nil? || /^x/ =~ issn
      render :partial => 'catalog/journal_rank', :locals => {:url => Rails.application.config.scopus_url % issn}       
    end
  end

  def render_dissertation_date args
    begin
      l args[:document][args[:field]].first.to_date, format: :long    
    rescue Exception
      args[:document][args[:field]].first
    end
  end

  def render_conference_info_index args
    (args[:document][args[:field]].first + ', ' + 
      render_journal_info(args[:document], :index) + 
      render_journal_page_info(args[:document], :index)).html_safe
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
