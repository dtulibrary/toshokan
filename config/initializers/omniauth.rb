Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas,
    :host => Toshokan::Application.config.cas[:host],
    :ssl => true
end
