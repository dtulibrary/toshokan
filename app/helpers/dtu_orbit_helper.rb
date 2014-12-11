module DtuOrbitHelper

  def dtu_orbit_backlink document
    href = (document['backlink_ss'] || []).select { |l| l.start_with? 'http://orbit.dtu.dk' }.first
    if href
      link_to(image_tag('dtu_rails_common/dtu.png'), href,
              :class => 'dtu-orbit-backlink',
              :title => t('toshokan.tools.metrics.dtu_orbit.title'))
    end 
  end 

end
