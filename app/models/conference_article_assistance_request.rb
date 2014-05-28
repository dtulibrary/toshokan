class ConferenceArticleAssistanceRequest < AssistanceRequest
  validates :article_title, :conference_pages, :conference_title, :conference_year, :presence => true

  def genre
    :conference_article
  end

  def title
    article_title
  end

  def author
    article_author
  end

  def openurl
    generate_openurl(['article', 'conference'], 'journal', 'proceeding')
  end

end
