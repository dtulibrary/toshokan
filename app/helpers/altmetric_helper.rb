module AltmetricHelper

  def render_altmetric_badge?(document)
    current?(document) && recognized_identifiers?(document)
  end

  def altmetric_badge(document, opts={})
    content_tag :div, class:'altmetric-wrapper' do
      identifiers = mendeley_identifiers(document)
      tag_attributes = {
        class: 'altmetric-embed',
        'data-badge-type' => 'donut',
        'data-badge-popover' => 'left',
        'data-hide-no-mentions' => 'true',
        'data-link-target' => '_blank'
      }
      ["data-badge-type", "data-badge-popover", :class].each do |attribute|
        if opts[attribute]
          tag_attributes[attribute] = opts[attribute]
        end
      end
      if identifiers[:doi]
        tag_attributes["data-doi"] = identifiers[:doi]
      end
      if identifiers[:pmid]
        tag_attributes["data-pmid"] = identifiers[:pmid]
      end
      if identifiers[:arxiv]
        tag_attributes["data-arxiv-id"] = identifiers[:arxiv]
      end

      content_tag :div, "", tag_attributes
    end
  end

  def altmetric_embed_script
    return "<script type='text/javascript' src='https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js'></script>".html_safe
  end

  def recognized_identifiers?(doc)
    # if there is an intersection '&' here,
    # then we have one or more of these id types
    (mendeley_identifiers(doc).keys & [:doi, :pmid, :arxiv]).present?
  end

  def current?(document)
    date = document['pub_date_tis'].try(:first)
    date.present? && date.try(:to_i) > 2010
  end
end
