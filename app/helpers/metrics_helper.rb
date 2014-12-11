module MetricsHelper
  
  def render_metrics? document
    document['format'] != 'journal' 
  end

end
