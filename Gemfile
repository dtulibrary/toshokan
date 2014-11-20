source 'https://rubygems.org'

gem 'rails', '~> 4.1.0'
gem 'activerecord-session_store'

gem 'jquery-rails', '~> 2.3.0'
gem 'blacklight', '~> 5.1.0'
gem 'unicode'
gem 'bootstrap-sass', '~> 3.2.0'

gem "blacklight_range_limit"
gem 'pg'
gem 'unhappymapper', :require => 'happymapper'
gem 'httparty'
gem 'hashie'
gem 'omniauth'
gem 'omniauth-cas'
gem 'omniauth-mendeley_oauth2'
gem 'cancancan'
gem 'acts-as-taggable-on'
gem 'dalli'
gem 'bibtex-ruby'
gem 'citeproc-ruby'
gem 'csl-styles'
gem 'netaddr'
gem 'openurl'
gem 'delayed_job_active_record'
gem 'uuidtools'
gem 'feature_flipper'
gem 'kaminari'
gem 'lisbn'
gem "rack-utf8_sanitizer", "~> 1.1.0"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'

  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
  gem 'findit_font', :git => 'git://github.com/dtulibrary/findit_font.git'
  gem 'autoprefixer-rails'
end

group :test do
  gem 'simplecov', :require => false
  gem 'simplecov-html', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'capybara'
  gem 'launchy'
  gem 'factory_girl_rails', "~> 4.0"
  gem 'webmock'
end

group :test, :development do
  gem 'jettywrapper'
  gem 'rspec-rails'
  gem 'metastore-test_data', :github => 'dtulibrary/metastore-test_data'
  gem 'sqlite3'
end

group :development do
  gem 'sass'
  gem 'brakeman'
  gem 'rails_best_practices'

  gem 'paint'
  # eventmachine 0.12.10 does not compile on windows
  gem 'eventmachine', '~> 1.0.0.rc4', :platforms => :mswin

  gem 'rails_view_annotator', '= 0.0.7'
  gem 'rails-footnotes'

  gem 'puma'
  gem 'quiet_assets'
  gem 'byebug'
end

# Deploy with Capistrano
gem 'capistrano', '~> 2.15'
gem 'rvm-capistrano', '~> 1.2.5'
