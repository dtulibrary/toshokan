class ThesisAssistanceRequest < AssistanceRequest
  validates :thesis_title, :thesis_author, :thesis_year, :presence => true

  def genre
    :thesis
  end

  def title
    thesis_title
  end

  def author
    thesis_author
  end

  def openurl
    generate_openurl(['thesis'], 'book', 'book')
  end

end
