module MetricsHelper
  
  def metrics
    ['altmetric_badge', 'link_to_dtu_orbit', 'link_to_pubmed', 'link_to_isi']
  end

  def render_metrics? document
    document['format'] != 'journal' && metrics.any? { |e| send("render_#{e}?", document) }
  end

  def render_metrics document
    metrics.select { |e| send("render_#{e}?", document) }.collect { |e|
      content_tag( 'div', send(e, document), :class => 'metric' )
    }.join.html_safe
  end

end
