module MetricsHelper
  
  def metrics
    ['altmetric_badge', 'link_to_dtu_orbit', 'link_to_pubmed', 'link_to_isi']
  end

  def render_metrics? document
    document['format'] != 'journal' && metrics.any? { |e| send("render_#{e}?", document) }
  end

  def render_metrics document
    result = ''
    metrics.each do |e|
      if send("render_#{e}?", document)
        result += content_tag('div', send(e, document), :class => 'metric')
      end
    end
    result.html_safe
  end

end
