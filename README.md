# Toshokan

Toshokan is a search interface application based on Ruby on Rails and Blacklight, and is being developed at the Technical Information Center of Denmark.

See http://findit.dtu.dk

Toshokan means library in japanese.


## Requirements

Using ruby 2.1.4. If you're using RVM, you might have to install using `rvm install 2.1.4 --disable-binary` to avoid errors with certificates.

## Solr

Install a clean copy of solr and configure it to have our "toc" and "metadata" collections

    $ rake solr:clean
    $ rake solr:config

To start and stop solr, use

    $ rake solr:start    
    $ rake solr:stop
    
To refresh the configs for the collections (ie. metastore and toc) call this task with solr running:

    $ rake solr:config_collections
    $ rake solr:import

Calling config_collections deletes the cores and re-creates them so you have to re-import the data after refreshign the configs.

## Test Data

To index the test/sample data, run

    $ rake solr:index:all

## Testing

Install up solr, configure it and import the data with one rake task: 
    
    $ rake solr:setup_and_import

Then migrate the database and run the tests

    $ rake db:migrate
    $ rake db:seed
    $ rake db:test:prepare
    $ rake

Use `rake` instead of `rake spec` because there are both RSpec tests and Cucumber tests.