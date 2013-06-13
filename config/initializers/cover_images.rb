Rails.application.config.to_prepare do
  CoverImages.configure do |config|
    config.merge! Rails.application.config.cover_images
  end
end
