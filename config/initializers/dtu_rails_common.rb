module DtuRailsCommon
  class Engine < Rails::Engine
    config.dtu_font_enabled = Rails.application.config.try(:dtu_common_layout) && Rails.application.config.dtu_common_layout[:dtu_font_enabled]
  end
end
