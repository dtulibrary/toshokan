# encoding: utf-8
module TocHelper

  def toc_for document, params
    return nil unless document[:format] == 'journal'

    query = "issn_ss:(#{document[:issn_ss].join(' OR ')})"
    fl    = 'toc_key_s,issn_ss,pub_date_tis,journal_vol_ssf,journal_issue_ssf'
    sort  = 'pub_date_tsort desc, journal_vol_sort desc, journal_issue_sort desc'
    toc_data = toc_solr.get('select', :params => params.merge({ :q => query, :rows => 1000, :fl => fl, :sort => sort }))
    toc_data = toc_data.with_indifferent_access[:response][:docs]

    # do some field-name mapping here to make the view logic simpler
    toc_data.map{|t| {:year  => t[:pub_date_tis].first.to_i,
                      :vol   => t[:journal_vol_ssf].try(:first).to_i,
                      :issue => t[:journal_issue_ssf].try(:first).to_i,
                      :key   => t[:toc_key_s]}}

  rescue => e
    logger.error "#{e.class} #{e.message}"
    logger.warn "Could not get toc data for document with cluster id #{document[:cluster_id_ss]}."
    nil
  end

  def toc_solr
    @solr_toc ||= RSolr.connect(toc_solr_config)
  end

  def toc_solr_config
    { :url => blacklight_solr_config[:toc_url] }
  end

  def articles_for toc_key, params
    query = "toc_key_s:(#{toc_key})"
    sort  = 'journal_page_start_tsort asc'
    articles = blacklight_solr.get(blacklight_config.solr_path, :params => params.merge({:q => query, :sort => sort, :rows => 100}))
    articles.with_indifferent_access
  end

end
