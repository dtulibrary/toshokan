module Toshokan
  module BuildsToc
    extend ActiveSupport::Concern

    included do
      helper_method :dissect_toc_key
    end

    def toc_for document, params = {}, solr_params = {}
      # FIXME: this is a hack until we have journal records for all toc-issns
      if document[:format] == 'article' && document[:toc_key_s]
        issn, _, _, _ = dissect_toc_key(document[:toc_key_s])
        document[:toc_key_journal_exists] = (journal_id_for_issns([issn]) != nil)
      end

      return nil unless document[:format] == 'journal'

      # get facets counts per year to help us decide how much of the toc to display
      query = "issn_ss:(#{document[:issn_ss].join(' OR ')})"
      toc_facets = toc_solr.get('select', :params => solr_params.merge({ :q => query, :rows => 0,
                                                                         :facet => 'true', 'facet.field' => 'pub_date_tis', 'facet.sort' => 'index', 'facet.limit' => 1000, 'facet.mincount' => 1 }))

      toc_facets = toc_facets.dup.with_indifferent_access
      # toc_facets = ActiveSupport::HashWithIndifferentAccess.new_from_hash_copying_default(toc_facets)

      # build a list of years (in decreasing order) until we have at least `threshold`
      # volumes/issues to display
      # - but also such that we always show all volumes/issues for year
      # - and such that the current issue is always among the displayed
      # - and such that there is always one year displayed after the year of
      #   the current issue
      total = toc_facets[:response][:numFound]
      threshold   =  10
      year_window =   1

      query_years = []
      count = 0

      facets = Hash[*toc_facets[:facet_counts][:facet_fields][:pub_date_tis]]
      years = facets.keys.map(&:to_i).sort.reverse
      _, ensure_year, _, _ = dissect_toc_key(params[:key]) if params[:key]
      ensure_year ||= years.first

      if params[:all]
        count = total
      else
        years.each do |year|
          query_years << year.to_s
          count += facets[year.to_s]
          break if count > threshold && (ensure_year && year <= ensure_year-year_window)
        end
      end
      truncated = count < total

      # get toc entries from toc index
      query = "issn_ss:(#{document[:issn_ss].join(' OR ')})"
      query << " AND pub_date_tis:[#{query_years.last} TO #{query_years.first}]" unless query_years.empty? || params[:all]
      fl    = 'toc_key_s,issn_ss,pub_date_tis,journal_vol_ssf,journal_issue_ssf,journal_part_ssf'
      sort  = 'pub_date_tsort desc, journal_vol_tsort desc, journal_issue_tsort desc, journal_part_sort asc'
      toc_data = toc_solr.get('select', :params => solr_params.merge({ :q => query, :rows => count, :fl => fl, :sort => sort }))
      toc_docs = toc_data.dup.with_indifferent_access[:response][:docs]

      # - do some field-name mapping here to make the view logic simpler
      # - also sort (even thought we get results sorted by Solr) since the
      #   sort fields in Solr are erronously defined as string fields
      issues = toc_docs.map{|t| {:year  => t[:pub_date_tis].first.to_i,
                                 :vol   => t[:journal_vol_ssf].try(:first).to_i,
                                 :issue => t[:journal_issue_ssf].try(:first).to_i,
                                 :part  => t[:journal_part_ssf].try(:first),
                                 :key   => t[:toc_key_s]}}
                   .reject{|t| t[:year] < 1000}
                   .sort_by{|t| [-t[:year], -t[:vol], -t[:issue], t[:part] || '']}

      toc = { :issues => issues, :truncated => truncated }

      # setup data for prev/next links and fetch articles in current_issue
      if !issues.blank?
        current_toc_key = (params[:key] || issues.first[:key])
        if current_issue_index = issues.find_index{ |t| t[:key] == current_toc_key }
          toc[:current_issue]  = issues[current_issue_index]
          toc[:next_issue]     = issues[current_issue_index-1] if current_issue_index > 0
          toc[:previous_issue] = issues[current_issue_index+1] if current_issue_index < issues.size-1
          toc[:articles]       = articles_for(current_toc_key, search_builder.add_access_filter)[:response][:docs]
        end
      end

      return toc
      # rescue => e
      #   logger.error "#{e.class} #{e.message}"
      #   logger.warn "Could not get toc data for document with cluster id #{document[:cluster_id_ss]}."
      #   { :issues => {}, :truncated => false }
    end

    def toc_solr
      @solr_toc ||= RSolr.connect(toc_solr_config)
    end

    def toc_solr_config
      { :url => blacklight_config.connection_config[:toc_url] }
    end

    def articles_for toc_key, solr_params
      query = "toc_key_s:(#{toc_key})"
      sort  = 'journal_page_start_tsort asc'
      articles = repository.connection.get(blacklight_config.solr_path, :params => solr_params.merge({:q => query, :sort => sort, :rows => 100}))
      articles.dup.with_indifferent_access
    end

    def dissect_toc_key(key)
      issn, year_prime, vol, issue = key.split('|')
      return issn, 2099-year_prime.to_i, vol.to_i, issue.to_i
    end

  end
end

