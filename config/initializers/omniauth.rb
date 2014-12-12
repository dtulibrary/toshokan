Rails.application.config.middleware.use OmniAuth::Builder do
  cas_url = Rails.application.config.auth[:cas_url]
  provider :cas,
           :url        => cas_url,
           :name       => :cas,
           :setup      => true

  provider :mendeley, Rails.application.config.mendeley[:client_id], Rails.application.config.mendeley[:secret],
           :site  => Rails.application.config.mendeley[:url],
           :name  => :mendeley,
           :setup => true
end

OmniAuth.config.logger = Rails.logger

if Rails.application.config.auth[:stub]
  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:cas, {
    :uid => '1234'
  })
end
