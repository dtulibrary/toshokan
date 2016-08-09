# install dependencies
bundle install
# prepare test database
bundle exec rake --trace db:migrate
# load database from schema.rb
bundle exec rake db:test:load
# start solr test server 
bundle exec rake jetty:start
# index to solr test server
bundle exec rake metastore:testdata:index
# run tests
bundle exec rake
# stop solr test server
bundle exec rake jetty:stop
