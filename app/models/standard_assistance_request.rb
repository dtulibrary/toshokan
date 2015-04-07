class StandardAssistanceRequest < AssistanceRequest
  validates :standard_title, :standard_year, :presence => true

  def genre
    :standard
  end

  def title
    standard_title
  end

  def author
    'not applicable'
  end

  def openurl
    generate_openurl(['standard'], 'book', 'report')
  end

end
