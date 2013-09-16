desc "Read dlib export yaml and create contents in toshokan database"

task :import_from_dlib, [:filename] => :environment do |t, args|
  # load data
  args.with_defaults(:filename => "/tmp/dlib.yaml")
  dlib = load_user_data(args.filename)

  # connect to solr
  solr = RSolr.connect(Blacklight.solr_config)

  # process data
  dlib.each do |cwis, data| 
    puts "Processing data for user #{cwis}"

    user = ensure_user_exists(cwis)
    next unless user
    
    puts '  - bookmarks and tags'
    data[:records].each do |record|
      create_bookmark_and_tags(user, record, solr)
    end

    puts '  - saved searches'
    data[:saved_searches].each do |search|
    end

    puts '  - search alerts'
    data[:search_alerts].each do |alert|
    end

    puts '  - journal alerts'
    data[:journal_alerts].each do |alert|
    end

  end

end


def load_user_data(path)
  data = YAML.load(File.open(path)).with_indifferent_access

  puts "users: #{data.size}"
  [:records, :saved_searches, :search_alerts, :journal_alerts].each do |key|
    puts "#{key}: #{data.map{|cwis,u| u[key].size}.inject(0, :+)}"
  end
  data
end

def ensure_user_exists(cwis)
  ## Make sure that the user exists
  user_data = Riyosha.find_or_create_by_cwis(cwis)
  if user_data
    User.create_or_update_with_user_data(:cas, user_data)
  else
    nil
  end
end

def create_bookmark_and_tags(user, record, solr)
  document = get_document_for_record(record, solr)
  
  if document
    user.bookmark(document)
    record[:tags].each do |tag|
      puts "      #{tag}"
      user.tag(document, tag)
    end
  end
end

def get_document_for_record(record, solr)
  record_id = record[:id]
  tags      = record[:tags]
  fq = case record[:type]
       when 'article'
         ["member_id_ss:#{record_id}"]
       when 'journal'
         ["issn_ss:#{record_id}"]
       when 'book'
         ["member_id_ss:#{record_id}"]
       end
  
  fq << "access_ss:dtu"
  params = {:fq => fq}
  result = solr.toshokan(:params => params).with_indifferent_access
  document = begin 
               id = result[:response][:docs].first[:cluster_id_ss].first
               Hashie::Mash.new({ :id => id })
             rescue => e
               # puts e.class
               # puts e.message
               # puts e.backtrace
             end
  if document
    puts "    #{record[:type]}: #{record[:id]} => #{document.id}"
  else
    puts "    #{record[:type]}: #{record[:id]} => NOT FOUND"
  end
  document
end
