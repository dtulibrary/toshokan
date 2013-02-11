# encoding: utf-8
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def has_search_parameters?
    super or !params[:t].blank?
  end

  def snip_abstract args
    render_abstract_snippet args[:document]
  end

  def render_abstract_snippet document
    snippet = (document['abstract_t'] || ['No abstract']).first
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
    info << document['pub_date_ti'].first if document['pub_date_ti']
    info << "Volume #{document['journal_vol_s'].first}" if document['journal_vol_s']
    # TODO: Enable when journal part is available in solr
    # info << "Part #{document['journal_part_s'].first}" if format == :show && document['journal_part_s']
    info << "Issue #{document['journal_issue_s'].first}" if document['journal_issue_s']
    info << "pp. #{document['journal_page_s'].first}" if document['journal_page_s']
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
end
