require 'fileutils'

task :default => [:spec, :cucumber] 

namespace :tosho do
  
  desc "(Re-)Generate the secret token"
  task :generate_secret => :environment do
    include ActiveSupport
    File.open("#{Rails.root}/config/initializers/secret_token.rb", 'w') do |f|
      f.puts "#{Rails.application.class.parent_name}::Application.config.secret_token = '#{SecureRandom.hex(64)}'"
    end  
  end
  
  $solr_config = YAML.load_file(Rails.root + 'config/solr.yml')[Rails.env]  
  namespace :test do

    desc "Fetch from local repository and index"
    task :setup_index => ['jetty:stop', :setup, 'jetty:start', :index]

    desc "Index fixtures"
    task :index => :environment do
      puts "Indexing"
      solr = RSolr.connect :url => $solr_config["url"]
      solr.delete_by_query '*:*'
      xml = File.open("spec/fixtures/solr_data.xml", "r").read
      solr.update :data => xml
      solr.commit
    end  
  
    desc "Install solr configuration files and fixtures for development and test"
    task :setup => 'setup:local'

    namespace :setup do
          
      desc "Fetch from local repository"
      task :local => :environment do                                                    
        puts "Fetching from local maven repository..."
        name = Rails.application.config.metastore[:name]
        file_path = Rails.application.config.metastore[:maven_local_path] + 
                    "#{Rails.application.config.metastore[:group]}/#{name}/" + 
                    Rails.application.config.metastore[:version] + 
                    "/#{name}-*.tar"
        Dir.glob(file_path).each do |f|
          puts "Extracting"
          `tar xf #{f} -C /tmp/`
        end  

        install_solr(Rails.application.config.metastore)
      end  
      
      desc "Fetch from DTIC maven repository"
      task :maven => :environment do
        fetch_from_maven(Rails.application.config.metastore, false)
        install_solr(Rails.application.config.metastore)
      end     
      
      desc 'Fetch from DTIC maven repository asking for password'
      task :maven_pw => :environment do
        fetch_from_maven(Rails.application.config.metastore, true)
        install_solr(Rails.application.config.metastore)
      end
    end  
  end

  def fetch_from_maven(config, using_password)
    puts "Fetching from DTIC maven repository..."
    file_name = "#{config[:name]}-#{config[:version]}.tar"
    file_path = "#{config[:maven_dtic_path]}#{config[:group]}/#{config[:name]}/#{config[:version]}/#{file_name}"
    if using_password
      hl = HighLine.new
      user = hl.ask 'User: '
      password = hl.ask('Password: ') { |q| q.echo = '*' }
      `wget --user=#{user} --password=#{password} -O /tmp/#{file_name} #{file_path} --progress=dot:mega` 
    else
      `wget -O /tmp/#{file_name} #{file_path} --progress=dot:mega`
    end
    puts "Extracting"
    `tar xf /tmp/#{file_name} -C /tmp/`        
  end

  def install_solr(config)
    tmp_path = "/tmp/#{config[:name]}/solr"
    tmp_conf_path = "#{tmp_path}/collection1/conf"
    jetty_conf = "jetty/solr/collection1/conf"
    solr_url = $solr_config["url"].gsub("http://", "");

    puts "Creating solr configuration directory"
    FileUtils.mkdir_p(jetty_conf)

    puts "Copying solr configuration files"
    Dir["#{tmp_conf_path}/*.{html,txt}","#{tmp_conf_path}/*/"].each do |f|
      FileUtils.cp_r(f, jetty_conf)
    end
    FileUtils.cp("#{tmp_conf_path}/solrconfig-master-test.xml", "#{jetty_conf}/solrconfig.xml")
    FileUtils.cp(%W(#{tmp_conf_path}/schema.xml #{tmp_conf_path}/ds.xml #{tmp_conf_path}/search_handlers.xml #{tmp_conf_path}/warming_queries.xml), "#{jetty_conf}")
    Dir["#{tmp_path}-#{config[:solr_version]}*.war"].each do |f|
      FileUtils.cp(f, "jetty/webapps/solr.war")
    end
    FileUtils.cp("/tmp/#{config[:name]}/solr_data.xml", "spec/fixtures")

    File.open("jetty/webapps/VERSION", 'w').write(
      "#{config[:solr_version]}\n"
    )

    File.open("#{jetty_conf}/ds.xml", 'w').write(
      "<?xml version='1.0' encoding='UTF-8'?>\n"\
      "<str name='shards'>#{solr_url}</str>\n"
    )
    
    File.open("#{jetty_conf}/../../solr.xml", 'w').write(
      "<?xml version='1.0' encoding='UTF-8'?>\n"\
      "<solr persistent='true' sharedLib='lib'>\n"\
      "  <cores adminPath='/admin/cores'>\n"\
      "    <core name='collection1' instanceDir='collection1' />\n"\
      "  </cores>\n"\
      "</solr>\n"
    )

    FileUtils.rm_rf "/tmp/#{config[:name]}*"
    FileUtils.rm_rf "jetty/solr/data/index"

  end  

  def scramble(in_file, out_file)
    
    in_f = File.open(in_file)
    doc = Nokogiri::XML(in_f)
    in_f.close
    
    doc.root.children.each do |node|
      if node.name == 'doc' 
        node.children.each do |field_node|
          if !['format','access', 'cluster_id', 'source_type', 'pub_date'].include? field_node['name']
            field_node.content = field_node.content.split(//).shuffle.join
          end  
        end  
      end
    end          
    
    File.open(out_file, 'w') do |out_f|
      out_f.write doc
    end  
    
  end 
end

