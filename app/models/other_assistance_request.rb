class OtherAssistanceRequest < AssistanceRequest
  validates :other_title, :host_year, :presence => true

  def genre
    :other
  end

  def title
    other_title
  end

  def author
    other_author || 'Unspecified'
  end

  def openurl
    generate_openurl(['other', 'host'], 'journal', 'article')
  end

end
