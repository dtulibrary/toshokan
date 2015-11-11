class DtuDocumentPresenter < Blacklight::DocumentPresenter

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
    label ||= @document.highlight_field(opts[:label])
    label ||= @document.get(opts[:label], :sep => nil) if opts[:label].instance_of? Symbol
    label ||= opts[:label].call(@document, opts) if opts[:label].instance_of? Proc
    label ||= opts[:label] if opts[:label].is_a? String
    label ||= @document.id
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