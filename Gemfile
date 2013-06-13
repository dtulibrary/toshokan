source 'https://rubygems.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'jquery-rails'
gem 'blacklight', '4.1'
gem 'unicode'
gem 'bootstrap-sass', '~> 2.2.0'

gem "blacklight_range_limit", :git => 'git://github.com/dtulibrary/blacklight_range_limit.git'
gem 'pg'
gem 'unhappymapper', :require => 'happymapper'
gem 'httparty'
gem 'hashie'
gem 'omniauth'
gem 'omniauth-cas'
gem 'cancan'
gem 'acts-as-taggable-on'
gem 'dalli'
gem 'bibtex-ruby'
gem 'citeproc-ruby'
gem 'netaddr'
gem "gelf"
gem "lograge"
gem "openurl"
gem 'delayed_job_active_record'
gem 'uuidtools'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails',  '~> 3.2.1'

  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
end

group :test do
  gem 'simplecov', :require => false
  gem 'simplecov-html', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'capybara'
  gem 'launchy'
end

group :test, :development do
  gem 'jettywrapper'
  gem 'debugger'
  gem 'rspec-rails'
  gem 'metastore-test_data', :github => 'dtulibrary/metastore-test_data'
  gem 'sqlite3'
end

group :development do
  gem 'sass'
  gem 'brakeman'
  gem 'rails_best_practices'

  gem 'paint'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'guard-brakeman'
  gem 'guard-rails'
  gem 'guard-rails_best_practices'
  gem 'guard-migrate'
  gem 'highline'
  # eventmachine 0.12.10 does not compile on windows
  gem 'eventmachine', '~> 1.0.0.rc4', :platforms => :mswin
  gem 'rb-fsevent'
  gem 'ruby_gntp'

  gem 'rails_view_annotator'
  gem 'rails-footnotes'
end

# Deploy with Capistrano
gem 'capistrano'
gem 'rvm-capistrano'

# To use debugger
# gem 'debugger'
