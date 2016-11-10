require 'set'

namespace :orbit do
  desc 'Generate ORBIT lists'
  task :generate_lists => :environment do
    common_fq = Query.common_filter_query
    seen_docs = Set.new

    # Delete all documents that haven't been rejected. They will come back if they haven't been registered in ORBIT.
    QueryResultDocument.where(rejected: false)
                       .delete_all

    # Make sure we don't report any rejected documents again
    QueryResultDocument.where(rejected: true)
                       .each do |query_doc|
      seen_docs.add(query_doc.document_id)
    end

    # Run and report for each query (in the same order as they appear in the UI)
    Query.where(enabled: true)
         .order('name asc')
         .each do |q|
      puts "Running '#{q.name}':"

      solr        = Blacklight.solr
      cursor_mark = '*'
      doc_counter = 0

      loop do
        solr_fields = %w(
          id
          title_ts
          journal_title_ts
          conf_title_ts
          author_ts
          affiliation_ts
          pub_date_tis
          journal_vol_ssf
          journal_issue_ssf
          journal_page_ssf
          cluster_id_ss
          source_id_ss
        )

        solr_params = {
          :cursorMark => cursor_mark,
          :q          => q.query_string,
          :fq         => common_fq + ['NOT source_ss:orbit'],
          :rows       => 100,
          :facet      => false,
          :fl         => solr_fields.join(','),
          :sort       => 'id asc'
        }

        response = solr.get('toshokan', params: solr_params)
        print "Processing #{response['response']['numFound']} results: " if cursor_mark == '*'

        if response['cursorMark'] == cursor_mark
          q.latest_count = doc_counter
          q.run_at       = Time.new
          q.save
          break
        else
          response['response']['docs'].each do |doc|
            dedup = doc['cluster_id_ss'].first

            # We don't want docs to be included in the results for more than one query (the first one that is run).
            # This enables us to create catch-all queries that, when run after all the normal queries are run,
            # will search on very loose criteria that will probably also match a lot of the docs matched
            # by the normal queries without having the results from the pre
            next if seen_docs.include?(dedup)

            # Check for similar already registered document in ORBIT
            duplicate_params = {
              :q     => "title_txt_stop:(#{doc['title_ts'].first})",
              :fq    => common_fq + ['source_ss:orbit'],
              :rows  => 1,
              :facet => false
            }
            duplicate_response = solr.get('toshokan', params: duplicate_params)
            duplicate          = duplicate_response['response']['docs'].first

            # Create the result document unless it exists and is ignored
            doc_params = {
              :query       => q,
              :document_id => doc['cluster_id_ss'].first,
              :document    => doc,
            }
            doc_params[:duplicate] = duplicate unless duplicate.nil?

            if QueryResultDocument.where(query: q, document_id: dedup, rejected: true).empty?
              QueryResultDocument.create(doc_params) 
              doc_counter += 1
              print duplicate.nil? ? '-' : '+'
            else
              print 'R'
            end

            seen_docs.add(dedup)
          end
          cursor_mark = response['cursorMark']
        end
        puts "\n#{doc_counter} documents were added or updated."
      end
    end
  end

  desc 'Remove rejected documents that are now registered in ORBIT'
  task :clean_rejected => :environment do
    solr = Blacklight.solr
    QueryResultDocument.where(rejected: true)
                       .each do |query_doc|
      solr_params = {
        :q     => "cluster_id_ss:#{query_doc.document_id} AND source_ss:orbit",
        :rows  => 0,
        :facet => false
      }

      response = solr.get('toshokan', params: solr_params)

      if response['response']['numFound'].to_i > 0
        query_doc.delete
        puts "Deleted rejected document with dedup: #{query_doc.document_id} since it's now registered in ORBIT."
      end
    end
  end
end
