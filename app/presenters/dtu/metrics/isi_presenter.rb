module Dtu
  module Metrics
    class IsiPresenter < Dtu::Presenter
      presents :document

      def should_render?
        !!isi_url
      end

      def render
        link_to_isi
      end

      def isi_url
        return nil if document['isi_url_ssf'].blank?
        document['isi_url_ssf'].first
      end

      def link_to_isi
        return unless isi_url

        link_to( image_tag('isi_logo2.png'), isi_url,
          :class  => 'isi-backlink',
          :target => '_blank',
          :title  => t('toshokan.tools.metrics.isi.title'))

      end
    end
  end
end
