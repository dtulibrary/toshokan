module PresenterHelper


  def present(object, klass = nil)
    klass ||= presenter_class(object)
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

  # Picks the best Presenter class to use for +object+
  def presenter_class(object=SolrDocument.new)
    case object
      when SolrDocument
        blacklight_config.document_presenter_class
      else
        "#{object.class}Presenter".constantize
    end
  end

end