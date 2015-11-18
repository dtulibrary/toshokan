require 'net/http'

namespace :solr do

  task :environment do
    SolrWrapper.default_instance_options[:download_dir] ||= Rails.root.to_s + '/tmp' if defined? Rails
    SolrWrapper.default_instance_options.merge!({
      verbose: true,
      cloud: true,
      port: '8983',
      version: '5.3.1',
      instance_dir: 'solr',
      extra_lib_dir: 'solr_conf/lib'
    })
    @solr_instance = SolrWrapper.default_instance
  end

  SOLR_OPTIONS =

  desc 'Set up a clean solr, configure it and import sample data'
  task :setup_and_import => :environment do
    Rake::Task["solr:clean"].execute
    Rake::Task["solr:config"].execute
    Rake::Task["solr:import:metastore"].execute
    Rake::Task["solr:import:toc"].execute
  end

  desc 'Configure solr with toc and metastore collections'
  task :config => :environment do
    Rake::Task["solr:config_instance"].execute
    puts "   starting solr to set up collections"
    Rake::Task["solr:start"].execute
    Rake::Task["solr:config_collections"].execute
  end

  desc 'Run the solr_instance configure method (copies lib directories etc).'
  task :config_instance => :environment do
    puts "Stopping solr before configuring"
    Rake::Task["solr:stop"].execute
    puts "Configuring solr at #{File.expand_path(@solr_instance.solr_dir)}"
    @solr_instance.configure
  end

  desc 'Configure collections in the solr cloud'
  task :config_collections => :environment do
    puts "   creating metastore collection"
    @solr_instance.create_or_update('metastore', dir:'solr_conf/metastore/conf')
    puts "   creating toc collection"
    @solr_instance.create_or_update('toc', dir:'solr_conf/toc/conf')
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

end
