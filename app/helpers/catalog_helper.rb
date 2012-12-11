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

  def journal_info args
    document = args[:document]
    field = args[:field]
    "#{document[field].first} &mdash; #{render_journal_info(document)}".html_safe
  end

  def render_journal_info document
    info = []
    info << document['pub_date_ti'].first if document['pub_date_ti']
    info << "Volume #{document['journal_vol_s'].first}" if document['journal_vol_s']
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
    authors.collect { |author| link_to author, root_path(:q => author, :search_field => :author) }.join(', ').html_safe
  end

end
