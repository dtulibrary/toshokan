module DissertationDocumentHelper
  def render_dissertation_date args
    begin
      l args[:document][args[:field]].first.to_date, format: :long
    rescue Exception
      args[:document][args[:field]].first
    end
  end
end