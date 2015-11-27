# Toshokan

Toshokan is a search interface application based on Ruby on Rails and Blacklight, and is being developed at the Technical Information Center of Denmark.

See http://findit.dtu.dk

Toshokan means library in japanese.


## Requirements

Using ruby 2.1.4. If you're using RVM, you might have to install using `rvm install 2.1.4 --disable-binary` to avoid errors with certificates.

## Solr

To do everything with one rake task - install clean copy of solr, configure it and import the data: 
    
    $ rake solr:setup_and_import    

The full set of solr rake tasks are documented in the [README file of the dtu_blacklight_common gem](https://github.com/dtulibrary/dtu_blacklight_common#solr). 

## Test Data

To index the test/sample data, run

    $ rake solr:index:all

## Testing

Install solr, configure it and import the data with one rake task: 
    
    $ rake solr:setup_and_import

Then migrate the database and run the tests

    $ rake solr:setup_and_import
    $ rake db:migrate
    $ rake db:seed
    $ rake db:test:prepare
    $ rake

Use `rake` instead of `rake spec` because there are both RSpec tests and Cucumber tests.