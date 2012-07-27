
Toshokan::Application.config.metastore = {
  :name => "metastore-test",
  :version => "1.0-SNAPSHOT",
  :solr_version => "4.0",
  :group => "dk/dtu/dtic",
  :maven_local_path => "#{ENV['HOME']}/.m2/repository/",
  :maven_dtic_path => "http://maven.cvt.dk/"
}

