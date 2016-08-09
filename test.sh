bundle exec rake db:setup
bundle exec rake db:test:prepare
bundle exec rake jetty:start
bundle exec rake metastore:testdata:index

# should we run Cucumber tests on jenkins?
bundle exec rake

