Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas,
    :host => Toshokan::Application.config.cas[:host],
    :ssl => true,
    :name => :dtu_cas
end

if Toshokan::Application.config.stub_authentication
  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:cas, {
    :uid => "username",
    :info => { :name => "Test User" },  
    :extra => {
      :user => "username",
    }
  })
end
