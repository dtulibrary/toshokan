class GoogleAnalytics
  def self.set_custom_variable name, value
    @@dimensions_and_metrics ||= Hash.new
    @@dimensions_and_metrics[name] = value
  end

  def self.dimensions_and_metrics
    @@dimensions_and_metrics
  end
end
