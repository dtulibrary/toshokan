module Dtu
  module Metrics
    class PubmedPresenter < Dtu::Presenter
      presents :document

      def should_render?
        !!pubmed_url
      end

      def render
        link_to_pubmed
      end

      def pubmed_url
        return nil if document['pubmed_url_ssf'].blank?
        "#{document['pubmed_url_ssf'].first}?otool=#{Rails.application.config.pubmed[:dtu_id]}"
      end

      def link_to_pubmed
        return unless pubmed_url

        link_to( image_tag('pubmed_logo2.png'), pubmed_url,
          :class  => 'pubmed-backlink',
          :target => '_blank',
          :title  => t('toshokan.tools.metrics.pubmed.title'))

      end
    end
  end
end
