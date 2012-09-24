CoverImages.configure do |config|
  config.url = Toshokan::Application.config.cover_images[:url]
  config.api_key = Toshokan::Application.config.cover_images[:api_key]

  logger.warn 'config.url not set' unless config.url =~ /\S/
  logger.warn 'config.api_key not set' unless config.api_key =~ /\S/
end
