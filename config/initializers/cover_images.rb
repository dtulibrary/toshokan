# Configure cover images whenever reloading is done
Rails.application.config.to_prepare do
  CoverImages.configure do |config|
    config.url = Toshokan::Application.config.cover_images[:url]
    config.api_key = Toshokan::Application.config.cover_images[:api_key]
  end
  Rails.logger.debug 'Configured cover images'
end
