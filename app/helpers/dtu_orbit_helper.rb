module DtuOrbitHelper

  def should_render_link_to_dtu_orbit? document
    (document['backlink_ss'] || []).any? { |l| l.start_with? 'http://orbit.dtu.dk' }
  end

  def link_to_dtu_orbit document
    href = (document['backlink_ss'] || []).select { |l| l.start_with? 'http://orbit.dtu.dk' }.first
    if href
      link_to(image_tag('dtu_rails_common/dtu.png'), href,
              :class  => 'dtu-orbit-backlink',
              :target => '_blank',
              :title  => t('toshokan.tools.metrics.dtu_orbit.title'))
    end 
  end 

end
