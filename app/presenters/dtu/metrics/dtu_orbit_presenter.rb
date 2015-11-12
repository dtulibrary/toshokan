module Dtu
  module Metrics
    class DtuOrbitPresenter < Dtu::Presenter
      presents :document

      def should_render?
        (document['backlink_ss'] || []).any? { |l| l.start_with? 'http://orbit.dtu.dk' }
      end

      def render
        link_to_dtu_orbit
      end

      def link_to_dtu_orbit
        href = (document['backlink_ss'] || []).select { |l| l.start_with? 'http://orbit.dtu.dk' }.first
        if href
          link_to(image_tag('dtu_rails_common/dtu.png'), href,
                  :class  => 'dtu-orbit-backlink',
                  :target => '_blank',
                  :title  => t('toshokan.tools.metrics.dtu_orbit.title'))
        end
      end
    end
  end
end

