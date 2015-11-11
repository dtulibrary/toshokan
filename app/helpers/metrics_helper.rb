module MetricsHelper

  # Metrics that might be rendered for each document
  # Each of these must correspond to a set of helper methods for rendering the metric
  # ie. in order to render altmetric_badge you need
  #     * a method named `should_render_altmetric_badge?`
  #     * a method named `altmetric_badge`
  def metrics
    ['altmetric_badge', 'link_to_dtu_orbit', 'link_to_pubmed', 'link_to_isi']
  end

  # Check whether any metrics should be rendered for the document
  def render_metrics? document
    document['format'] != 'journal' && metrics.any? { |metric_name| should_render_metric?(metric_name, document) }
  end

  # Render all metrics that apply for +document+
  def render_metrics document
    metrics_content = []
    metrics.each do |metric_name|
      if should_render_metric?(metric_name, document)
        metrics_content << content_tag( 'div', render_metric(metric_name, document), :class => 'metric' )
      end
    end
    metrics_content.join.html_safe
  end

  # Check whether the metric should be rendered for the +document+
  def should_render_metric?(metric_name, document)
    tester_method_name = "should_render_#{metric_name}?"
    result = respond_to?(tester_method_name) ? send(tester_method_name, document) : false
  end

  # Render the metric called +metric_name+ for +document+
  def render_metric(metric_name, document)
    send(metric_name, document) if respond_to? metric_name
  end

end
