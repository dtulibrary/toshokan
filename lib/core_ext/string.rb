class String
  def issn?
    /^\d{4}-?\d{3}[\dxX]$/.match(self) != nil
  end
end
