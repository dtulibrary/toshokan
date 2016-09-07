require File.expand_path('../boot', __FILE__)

require 'rails/all'



if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Toshokan
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib/document)
    config.eager_load_paths += %W(#{config.root}/lib/document)
    config.railties_order = [:main_app, DtuRailsCommon::Engine, Blacklight::Engine, :all]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true
    # Default SASS Configuration, check out https://github.com/rails/sass-rails for details
    config.assets.compress = !Rails.env.development?

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.2'

    # Enable I18n fallbacks
    config.i18n.fallbacks  = true
    config.i18n.load_path += Dir[File.join(Rails.root, 'config', 'locales', '**', '*.{rb,yml}')]

    # Sanitize UTF8 input
    config.middleware.insert_before "Rack::Runtime", Rack::UTF8Sanitizer

    # Make IE behave as a browser
    config.action_dispatch.default_headers.merge!('X-UA-Compatible' => 'IE=edge')

    # Config to be overriden by local settings
    config.time_zone                      = 'CET'
    config.active_record.default_timezone = :local

    config.application_name = 'DTU Findit'

    config.solr_document = {
      :document_id => 'cluster_id_ss'
    }

    config.search = {
      :dtu => 'dtu',
      :pub => 'dtupub'
    }

    config.auth = {
      :stub    => false,
      :cas_url => 'http://localhost:3001/users',
      :api_url => 'http://localhost:3001/rest',
      :ip      => {
        :walk_in  => [],
        :campus   => [],
        :internal => [],
      }
    }

    config.cover_images = {
      :url     => 'http://covers:3000',
      :api_key => ''
    }

    config.getit = {
        :url => 'http://localhost:3003'
    }

    config.action_mailer.smtp_settings = {
    }

    config.alis_url = ''

    config.orders = {
      # Prefix order id's since we use unique order id's in DIBS
      # and development machines, unstable, staging and production all use the same DIBS
      :order_id_prefix   => 'N/A-',
      :reply_to_email    => '',
      :order_link_hidden => true,
      :enabled           => true,
      :enabled_ips       => [],
      :terms_of_service  => {
        :en => 'http://lgdata.s3-website-us-east-1.amazonaws.com/docs/3935/791908/DTUFindit_TermsAndConditions.pdf',
        :da => 'http://lgdata.s3-website-us-east-1.amazonaws.com/docs/3935/791910/DTUFindit_Handelsbetingelser.pdf',
      },
    }

    config.dibs = {
      :payment_url => 'https://payment.architrade.com/paymentweb/start.action',
      :capture_url => 'https://payment.architrade.com/cgi-bin/capture.cgi',
      :cancel_url  => 'https://payment.architrade.com/cgi-adm/cancel.cgi',
      :username    => '',
      :password    => '',
      :merchant_id => '',
      :md5_key1    => '',
      :md5_key2    => '',
      :paytype     => 'DK,VISA,ELEC,MC,MTRO,AMEX,JCB',
      :test        => true,
    }

    config.metadata = {
      :url => ''
    }

    config.doc_del = {
      :url     => 'http://docdel:3000',
      :enabled => true,
      :timeout => 10*60, # 10 minutes
    }

    config.send_it = {
      :url                   => 'http://sendit:3000',
      :delay_jobs            => false,
      :timeout               => 10*60, # 10 minutes
      :delivery_support_mail => '',
      :book_suggest_mail     => '',
      :feedback_mail         => '',
      :patlib_mail           => '',
    }

    config.library_support = {
      :url         => '',
      :timeout     => 10*60, # 10 minutes
      :api_key     => '',
      :reply_to    => '',
      :project_ids => {
        :journal_article    => '',
        :conference_article => '',
        :book               => '',
        :failed_requests    => '',
      },
      # TODO: When the library support Redmine instance is updated
      #       to version >= 2.4, the custom fields should be retrieved
      #       dynamically from Redmine instead of this hard config.
      #       See #1591
      :custom_fields => {
        :dtu_unit => {
          :id   => '1',
          :name => 'DTU Unit',
        },
        :failed_from => {
          :id   => '10',
          :name => 'Failed from',
        },
        :book_suggest => {
          :id   => '13',
          :name => 'Books Suggestion',
        },
        :reordered => {
          :id   => '15',
          :name => 'Reordered',
        },
      },
    }

    config.delay_jobs = false

    config.scopus_url = "http://www.scimagojr.com/journalsearch.php?q=%s&tip=iss"
    config.orbit_url  = "http://orbit.dtu.dk/en/publications/id(%s).html"

    config.lib_guide = {
      :public => {
        :how_to => 'http://libguides.dtu.dk/content.php?pid=462533&sid=3821789#13839230',
      }
    }

    config.google_analytics = {
      :tracking_id => nil,
    }

    config.alert = {
      :url       => 'http://alert:3000',
      :test_mode => false,
    }

    config.google = {
      :maps_v3 => {
        :api_key => '',
      }
    }

    config.rsolr = {
      :retries     => 3,
      :retry_delay => 0.1,
    }

    config.resolve = {
      :sfx_url => 'http://sfx.cvt.dk/sfx_local'
    }

    config.pubmed = {
      :url    => "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?id=%<id>s&db=pubmed&retmode=xml&tool=%<tool>s&email=%<email>s",
      :tool   => '',
      :email  => '',
      :dtu_id => ''
    }

    config.mendeley = {
      :url       => 'https://mix.mendeley.com',
      :client_id => '',
      :secret    => '',
    }

  end
end
