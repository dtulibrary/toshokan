# encoding: utf-8
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  ##  DELETE THIS METHOD after upgraded to blacklight 5.7+ it will be provided by Blacklight::CatalogHelperBehavior
  # Should we display the pagination controls?
  #
  # @param [Blacklight::SolrResponse]
  # @return [Boolean]
  def show_pagination? response = nil
    response ||= @response
    response.limit_value > 0
  end

  def has_search_parameters?
    result = super || !params[:t].blank? || !params[:l].blank? || !params[:resolve].blank?
  end

  def add_access_filter solr_parameters = {}, user_parameters = {}
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "access_ss:#{Rails.application.config.search[:dtu]}" if can? :search, :dtu
    solr_parameters[:fq] << "access_ss:#{Rails.application.config.search[:pub]}" if can? :search, :public
    solr_parameters
  end

  def add_inclusive_access_filter solr_parameters = {}, user_parameters = {}
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "access_ss:(#{Rails.application.config.search[:dtu]} OR #{Rails.application.config.search[:pub]})"
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
    (link_to_if(has_journal,
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
    (link_to_if(false && has_toc,  # disabled until we have journal records for all toc-issns
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
    if document['journal_page_ssf']
      ", #{I18n.t('toshokan.catalog.toc.page')} #{document['journal_page_ssf'].first}"
    else
      ''
    end
  end

  def render_doi_link args
    doi = args[:document][args[:field]].first
    link_to doi, "http://dx.doi.org/#{doi}"
  end

  def render_author_links args

    if args[:document]['author_affiliation_ssf']
      render_author_list args[:document]['author_affiliation_ssf'].first, {:author_with_affiliation => true}
    else
      render_author_list args[:document][args[:field]]
    end
  end

  def render_shortened_author_links args
    render_author_list args[:document][args[:field]], { :max_length => 3, :append => I18n.t('toshokan.catalog.shortened_list.et_al') }
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
    (args[:document][args[:field]].first + ' &mdash; ' +
      render_journal_info(args[:document], :index) +
      render_journal_page_info(args[:document], :index)).html_safe
  end

  def render_conference_info_show args
    if args[:document]['journal_title_ts']
      args[:document][args[:field]].first.html_safe
    else
      render_conference_info_index args
    end
  end

  def render_issn args, separator = ', '
    args[:document][args[:field]].collect {|issn| issn.sub /^(.{4})/, '\1-'}.join(separator).html_safe
  end

  def render_isbn args, separator = ', '
    args[:document][args[:field]].collect {|isbn| (Lisbn.new(isbn).parts || [isbn]).join '-'}.join(separator).html_safe
  end

  def render_issn_index args
    render_issn args
  end

  def render_issn_show args
    render_issn args, '<br>'
  end

  def render_isbn_index args
    render_isbn args
  end

  def render_isbn_show args
    render_isbn args, '<br>'
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

    b = normalize_year(b) if b.is_a? Integer
    e = normalize_year(e) if e.is_a? Integer

    if b.is_a?(Integer) && e.is_a?(Integer) && b > e
      e = b
    end

    normalized_range = { 'begin' => b.to_s, 'end' => e.to_s }

    if normalized_range != range
      logger.info "Normalized range #{range} to #{normalized_range}"
    end

    normalized_range
  end

  # needed for synthesized records via resolver

  def render_link_rel_alternates(document=@document, options = {})
    params[:resolve].blank? ? super : ""
  end

  def extra_body_classes
    controller_name = controller.controller_name
    controller_action = controller.action_name
    unless params[:resolve].blank?
      controller_name = CatalogController.controller_name
      controller_action = "show"
    end
    @extra_body_classes ||= ['blacklight-' + controller_name, 'blacklight-' + [controller_name, controller_action].join('-')]
  end

  def export_search_result(format_name, params, extra_search_params)
    params.delete('per_page')
    params['page'] = 1
    params['rows'] = blacklight_config.max_per_page
    (response, document_list) = get_search_results(params, extra_search_params)

    case format_name
    when :bib
      # Add references to a BibTex::Bibliography to ensure that bibtex
      # keys are unique within exported file
      bibliography = BibTeX::Bibliography.new
      document_list.each do |document|
        bibliography.add(document.export_as(:bib))
      end
      bibliography.map{|entry| entry.to_s}.join("\n")
    when :ris
      document_list.map{|document| document.export_as(:ris)}.join("\n\n")
    end

  end

end
