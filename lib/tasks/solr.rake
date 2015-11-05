require 'net/http'

namespace :solr do
  SOLR_OPTIONS = {
      verbose: true,
      cloud: true,
      port: '8983',
      version: '5.3.1',
      instance_dir: 'solr',
      extra_lib_dir: 'solr_conf/lib'
  }

  desc 'Set up a clean solr, configure it and import sample data'
  task :setup_and_import => :environment do
    Rake::Task["solr:clean"].execute
    Rake::Task["solr:config"].execute
    Rake::Task["solr:import:metastore"].execute
    Rake::Task["solr:import:toc"].execute
  end

  desc 'Configure solr with toc and metastore collections'
  task :config => :environment do
    puts "Stopping solr before configuring"
    Rake::Task["solr:stop"].execute
    puts "Configuring solr at #{File.expand_path(@solr_instance.solr_dir)}"
    @solr_instance.configure
    puts "   starting solr to set up collections"
    Rake::Task["solr:start"].execute
    puts "   adding configs for metastore to zookeeper"
    zk_upload_config(@solr_instance, 'metastore')
    puts "   adding configs for toc to zookeeper"
    zk_upload_config(@solr_instance, 'toc')
    puts "   creating metastore collection"
    create_solr_collection(@solr_instance, 'metastore')
    puts "   creating toc collection"
    create_solr_collection(@solr_instance, 'toc')
    puts "finished configuring. Solr is running."
  end

  namespace :import do
    desc "Import all sample data into solr"
    task :all => [:metastore, :toc]

    desc "Import metastore sample data"
    task :metastore => :environment do
      puts "Importing metastore sample data"
      post_solr_data(@solr_instance, 'metastore', 'spec/fixtures/solr_data.xml')
    end

    desc "Import toc sample data"
    task :toc => :environment do
      puts "Importing toc sample data"
      post_solr_data(@solr_instance, 'toc', 'spec/fixtures/toc_data.xml')
    end
  end

  # Post the data from +path_to_data+ to collection +collection_name+ in +solr_instance+
  def post_solr_data(solr_instance, collection_name, path_to_data)
    result = %x{curl '#{solr_instance.url}#{collection_name}/update?commit=true&wt=json' -d @#{path_to_data}}
    begin
      json = JSON.parse(result)
      if json['responseHeader']['status'] == 0
        puts "   import successful"
      else
        puts result
      end
    rescue
      puts result
    end
  end

  # Use zookeeper cli script to upload configs for +collection_name+ into +solr_instance+
  def zk_upload_config(solr_instance, collection_name, conf_dir=nil)
    conf_dir ||= "solr_conf/#{collection_name}/conf"
    zkhost = "localhost:#{solr_instance.port.to_i+1000}"
    zkcli = "#{solr_instance.solr_dir}/server/scripts/cloud-scripts/zkcli.sh"
    # make zookeeper script executable
    File.chmod(0744, zkcli)
    %x{#{zkcli} -cmd upconfig --confdir #{conf_dir} --confname #{collection_name} --zkhost #{zkhost} --solrhome #{File.expand_path(solr_instance.solr_dir)}}
  end

  # Tell solr admin api on +solr_instance+ to create a collection named +collection_name+
  def create_solr_collection(solr_instance, collection_name)
    begin
      response = open "#{solr_instance.url}admin/collections?action=CREATE&name=#{collection_name}&numShards=1&replicationFactor=1&wt=json"
    rescue OpenURI::HTTPError => e
      begin
        # If the collection already exists, this error is fine.
        json = JSON.parse(e.io.read)
        response = e.io
        raise RuntimeError unless json['error']['msg'] == "collection already exists: #{collection_name}"
      rescue
        raise RuntimeError, "OpenURI::HTTPError: " + e.io.read
      end
    end
    response.read
  end

end
