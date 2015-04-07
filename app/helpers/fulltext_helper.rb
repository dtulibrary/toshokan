module FulltextHelper
  def render_access_prohibited_option?
    @document['format'] == 'thesis' && ['master', 'bachelor', 'diploma_bachelor'].include?(@document['subformat_s'])
  end
end
