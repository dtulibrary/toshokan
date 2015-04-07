class PatentAssistanceRequest < AssistanceRequest
  validates :patent_title, :patent_year, :presence => true

  def genre
    :patent
  end

  def title
    patent_title || 'Unspecified'
  end

  def author
    patent_inventor || 'Unspecified'
  end

  def openurl
    generate_openurl(['article', 'journal'], 'journal', 'article')
  end

end
