Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas,
           :host  => Rails.application.config.auth[:cas_url].gsub(/^https?:\/\//, ''),
           :ssl   => Rails.application.config.auth[:cas_url].start_with?('https://'),
           :name  => :cas,
           :setup => true
end

OmniAuth.config.logger = Rails.logger

if Rails.application.config.auth[:stub]
  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:cas, {
    :uid => '1234'
  })
end
