require 'set'
require 'faraday'

RETRY_DELAY_IN_SECONDS = 5

namespace :orbit do
  desc 'Generate ORBIT lists'
  task :generate_lists => :environment do
    common_fq = Query.common_filter_query
    seen_docs = Set.new

    # Run and report for each query (in the same order as they appear in the UI)
    Query.where(enabled: true)
         .order('name asc')
         .each do |q|
      puts "Running '#{q.name}':"

      q.run_at      = Time.new
      cursor_mark   = '*'
      doc_counter   = 0
      query_string  = Query.normalize(q.query_string)
      rejected_docs = Set.new

      # Delete all documents that haven't been rejected for this query.
      # They will come back if they haven't been registered in ORBIT.
      QueryResultDocument.where(rejected: false, query: q)
                         .delete_all

      # Fetch all documents that were rejected for this query
      QueryResultDocument.where(rejected: true, query: q)
                         .each do |query_doc|
        rejected_docs.add(query_doc.document_id)
      end

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
          :q          => query_string,
          :fq         => common_fq + ['NOT source_ss:orbit'],
          :rows       => 100,
          :facet      => false,
          :fl         => solr_fields.join(','),
          :sort       => 'id asc'
        }

        response = solr_post('toshokan', params: solr_params)

        next if response.nil?

        puts "Processing #{response['response']['numFound']} documents:" if cursor_mark == '*'

        response['response']['docs'].each do |doc|
          dedup = doc['cluster_id_ss'].first

          # Skip rejected document
          next if rejected_docs.include?(dedup)

          # Skip document if it was processed by previous queries and this query has filter flag set
          next if q.filter && seen_docs.include?(dedup)

          # Check for similar already registered document in ORBIT
          duplicate_params = {
            :q     => "title_txt_stop:(#{doc['title_ts'].first})",
            :fq    => common_fq + ['source_ss:orbit'],
            :rows  => 1,
            :facet => false
          }
          duplicate_response = solr_post('toshokan', params: duplicate_params)
          duplicate          = duplicate_response['response']['docs'].first

          # Create the result document unless it exists and is rejected
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

        # Check for end of result
        if response['nextCursorMark'] == cursor_mark
          q.latest_count = doc_counter
          q.save
          puts "\n#{doc_counter} documents were added or updated."
          break
        else
          cursor_mark = response['nextCursorMark']
        end
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

  def solr_post(path, options = {})
    response = nil
    loop do
      begin
        response = Blacklight.solr.post(path, options)
        break if !response.nil? && response['responseHeader']['status'] == 0
      rescue Faraday::ClientError => e
        STDERR.puts "Client error: #{e.message}."
      rescue Errno::ECONNREFUSED => e
        STDERR.puts "Connection refused: #{e.message}."
      end
      STDERR.puts "Waiting #{RETRY_DELAY_IN_SECONDS} to try again..."
      sleep RETRY_DELAY_IN_SECONDS
    end
    response
  end
end
