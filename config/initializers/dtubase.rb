Dtubase.configure do |config|
  config.url      = Toshokan::Application.config.dtubase[:url]
  config.username = Toshokan::Application.config.dtubase[:username]
  config.password = Toshokan::Application.config.dtubase[:password]
end
