module OrbitDocumentHelper

  def should_render_orbit_backlink? document
    document['backlink_ss'] && document['source_ss'].include?('orbit')
  end

  def extract_orbit_backlink document
    document['backlink_ss'].select {|link| link.start_with? 'http://orbit.dtu.dk'}.first
  end

end
