Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas,
    :host => Toshokan::Application.config.cas[:host],
    :ssl => true
end

if Toshokan::Application.config.stub_authentication
  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:cas, {
    :uid => "username",
    :info => { :name => "Test User" },  
    :extra => {
      :norEduPerson => [{
        :norEduPersonLIN => "0"
      }]
    }
  })
end