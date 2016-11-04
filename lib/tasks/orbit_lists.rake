namespace :orbit do
  desc 'Generate ORBIT lists'
  task :generate_lists => :environment do
    common_fq = Query.common_filter_query
    Query.where(enabled: true).each do |q|
      puts "Running '#{q.name}':"
      # Delete all documents that haven't been rejected. They will come back if they haven't been registered in ORBIT.
      QueryResultDocument.where(query_id: q.id, rejected: false).delete_all
      solr = Blacklight.solr
      cursor_mark = '*'
      doc_counter = 0
      loop do
        solr_fields = %w(id
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
                         source_id_ss)
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
          q.run_at = Time.new
          q.save
          break
        else
          response['response']['docs'].each do |doc|
            # Check for similar already registered document in ORBIT
            duplicate_params = {
              :q     => "title_txt_stop:(#{doc['title_ts'].first})",
              :fq    => common_fq + ['source_ss:orbit'],
              :rows  => 1,
              :facet => false
            }
            duplicate_response = solr.get('toshokan', params: duplicate_params)
            duplicate          = duplicate_response['response']['docs'].first

            # Delete any rejected document that is now in ORBIT (it is automatically rejected by the search)
            QueryResultDocument.where(document_id: duplicate['cluster_id_ss'].first, rejected: true).delete_all unless duplicate.nil?

            # Create the result document unless it exists and is ignored
            doc_params = {
              :query       => q,
              :document_id => doc['cluster_id_ss'].first,
              :document    => doc,
            }
            doc_params[:duplicate] = duplicate unless duplicate.nil?
            if QueryResultDocument.where(query: q, document_id: doc['cluster_id_ss'].first, rejected: true).empty?
              QueryResultDocument.create(doc_params) 
              doc_counter += 1
              print duplicate.nil? ? '-' : '+'
            else
              print 'R'
            end
          end
          cursor_mark = response['cursorMark']
        end
        puts "\n#{doc_counter} documents were added or updated."
      end
    end
  end
end
