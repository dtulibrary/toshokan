module Dtu
  class DocumentPresenter < Blacklight::DocumentPresenter
    # These modules are defined in app/presenters/concerns/dtu
    include Dtu::PresenterBehavior
    include Dtu::DocumentPresenter::Metrics

    presents :document

    # These overrides are for compatibility with Blacklight::DocumentPresenter
    # @see https://github.com/projectblacklight/blacklight/issues/1328
    # @see https://github.com/projectblacklight/blacklight/issues/1329
    def initialize(object, view_context, configuration=nil)
      configuration = view_context.try(:blacklight_config) if configuration.nil?
      super
      @configuration = configuration
      @controller = view_context # for compatibility with Blacklight::DocumentPresenter
      @document = object # for compatibility with Blacklight::DocumentPresenter
    end

    ###
    # Overrides to methods in default Blacklight::DocumentPresenter
    ###

    ##
    # Render the document index heading
    # Overrides blacklight default implementation in order to make values highlighted if a highlighted version is available
    #
    # @param [Hash] opts
    # @option opts [Symbol] :label Render the given field from the document
    # @option opts [Proc] :label Evaluate the given proc
    # @option opts [String] :label Render the given string
    def render_document_index_label opts = {}
      label = nil
      label ||= document.highlight_field(opts[:label])
      label ||= document.get(opts[:label], :sep => nil) if opts[:label].instance_of? Symbol
      label ||= opts[:label].call(document, opts) if opts[:label].instance_of? Proc
      label ||= opts[:label] if opts[:label].is_a? String
      label ||= document.id
      render_field_value label
    end

    # Overrides blacklight default implementation making it return the original value if there are no highlights
    def get_field_values field, field_config, options = {}
      value = super
      if value.nil? && field_config && field_config.highlight
        config_dup = field_config.dup
        config_dup.highlight = false
        value = get_field_values field, config_dup
      end
      value
    end
  end
end
