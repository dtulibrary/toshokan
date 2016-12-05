# Hook into process_action notifications to monitor time for all searches
ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
    data = args.extract_options!
    status = data[:status] || 0
    if status == 500
      message = {
        status: status,
        path: data[:path],
        action: "#{data[:params]['controller']}##{data[:params]['action']}"
      }
      Monitor.server_error(message)
    elsif data[:controller] == 'CatalogController' && data[:action] == 'index'
      event = ActiveSupport::Notifications::Event.new(*args, data)
      path = data[:path] || ''
      duration = event.duration.round(0)
      Monitor.response_time(duration, path, status)
    end
end

class Monitor
  def self.server_error(messages)
    if enabled?
      DtuMonitoring::InfluxWriter.delay(priority: 0).write(
        "events",
        { app: Rails.application.config.monitoring_id },
        messages,
        (Time.now.to_f * 1000).round)
    end
  end

  def self.response_time(duration, path, status)
    if enabled?
      DtuMonitoring::InfluxWriter.delay(priority: 0).write(
        "search_response_time",
        { app: Rails.application.config.monitoring_id },
        { value: duration, path: path, status: status},
        (Time.now.to_f * 1000).round)
    end
  end

  def self.enabled?
    Rails.application.config.try(:monitoring_id) && Rails.application.config.monitoring_id.present?
  end
end
