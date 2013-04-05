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

  def render_holdings args
    holdings = {}
    args[:document][args[:field]].each { |h|
      holding = JSON.parse(h)
      if(holding["type"] == "printed")
        holdings[holding["type"]] ||= []
        holdings[holding["type"]] << holding
      end
    }
    if holdings.size > 0
      holdings.each { |type, holding|
        holding.sort! {|x, y| x['fromyear'] <=> y['fromyear'] }
      }

      issn = args[:document]['issn_ss'].first
      render :partial => 'catalog/holdings', :locals => {:holdings => holdings, :issn => issn}
    else
      I18n.t("toshokan.catalog.holdings.placeholder")
    end
  end

  def render_alis_link args
    render :partial => 'catalog/alis_link', :locals => {:alis_key => args[:document][args[:field]].first}
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

end
