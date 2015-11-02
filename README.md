# Toshokan

Toshokan is a search interface application based on Ruby on Rails and Blacklight, and is being developed at the Technical Information Center of Denmark.

See http://findit.dtu.dk

Toshokan means library in japanese.


## Requirements

Using ruby 2.1.4. If you're using RVM, you might have to install using `rvm install 2.1.4 --disable-binary` to avoid errors with certificates.

## Test Data

To index test data from metastore, run

    $ rake metastore:testdata:index

## Testing

Jetty is included in the git repository, so you don't need to install it.

If you haven't indexed the test data, do that:

    $ rake metastore:testdata:index

Then migrate the database and run the tests

    $ rake db:migrate
    $ rake db:seed
    $ rake db:test:prepare
    $ rake

Use `rake` instead of `rake spec` because there are both RSpec tests and Cucumber tests.