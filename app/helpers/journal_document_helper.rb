module JournalDocumentHelper

  def render_journal_info args, format = :show
    document = args[:document]
    field = args[:field]
    has_toc  = document[:toc_key_s] && document[:issn_ss]
    has_journal = document[:toc_key_s] && document[:toc_key_journal_exists] && document[:issn_ss]
    # displaying journal as link in index views is disabled until we have journal records for all toc-issns
    if format == :index
      has_journal = false
    end
    (link_to_if(has_journal,
                document[field].first,
                catalog_journal_path(:issn => document[:issn_ss], :key => document[:toc_key_s], :ignore_search => '✓'),
                { :title => I18n.t('toshokan.catalog.toc.open_table_of_contents'), :data => { :toggle => 'tooltip' } }) +
        ' — ' +
        link_to_toc_query_if(has_toc && !limit_in_params?(:toc), render_journal_metadata(document, :show), document[:toc_key_s], (document[:journal_title_ts] || document[:conf_title_ts]).first) +
        render_journal_page_info(document, :show)).html_safe
  end

  def render_journal_info_show args, format = :show
    render_journal_info args, format
  end

  def render_journal_info_index args, format = :index
    render_journal_info args, format
  end

  def render_conference_info_index args
    (args[:document][args[:field]].first + ' &mdash; ' +
        render_journal_info(args, :index) +
        render_journal_page_info(args[:document], :index)).html_safe
  end

  def render_conference_info_show args
    if args[:document]['journal_title_ts']
      args[:document][args[:field]].first.html_safe
    else
      render_conference_info_index args
    end
  end

  def render_journal_metadata document, format
    render_journal_metadata_from_parts(
        document['pub_date_tis']      && document['pub_date_tis'].first,
        document['journal_vol_ssf']   && document['journal_vol_ssf'].first,
        document['journal_issue_ssf'] && document['journal_issue_ssf'].first,
        document['journal_part_ssf']  && document['journal_part_ssf'].first)
  end

  def render_journal_metadata_from_parts year, vol, issue, part
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

  def render_journal_rank(document)
    issn = document['issn_ss'].try(:first) || nil
    unless issn.nil? || /^x/ =~ issn
      render :partial => 'catalog/journal_rank', :locals => {:url => Rails.application.config.scopus_url % issn}
    end
  end

end
