CoverImages.configure do |config|
  config.url = Toshokan::Application.config.cover_images[:url]
  config.api_key = Toshokan::Application.config.cover_images[:api_key]
end
