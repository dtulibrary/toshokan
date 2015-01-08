# encoding: utf-8
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  # Should we display the pagination controls?
  #
  # @param [Blacklight::SolrResponse]
  # @return [Boolean]
  def show_pagination? response = nil
    response ||= @response
    response.limit_value > 0 && response.total_pages > 1
  end

  def extra_body_classes
    controller_name = controller.controller_name
    controller_action = controller.action_name
    unless params[:resolve].blank?
      controller_name = CatalogController.controller_name
      controller_action = "show"
    end
    ['blacklight-' + controller_name, 'blacklight-' + [controller_name, controller_action].join('-')]
  end

  # Extends default behavior to inject .homegrown class if content is from "local" source
  def render_document_class(document = @document)
    document_classes = super(document) ? [super(document)] : []
    if homegrown_content?(document)
      document_classes << "homegrown"
    end
    return document_classes.join(' ')
  end

  # Returns true if the document is from a "local" source
  def homegrown_content?(document = @document)
    (document['source_ss'] || []).any? { |s| ['orbit','sorbit'].include? s }
  end

end
