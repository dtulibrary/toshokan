class JournalArticleAssistanceRequest < AssistanceRequest
  validates :article_title, :journal_title, :journal_volume, :journal_year, :journal_pages, :presence => true

  def genre
    :journal_article
  end

  def title
    article_title
  end

  def author
    article_author
  end

  def openurl
    generate_openurl(['article', 'journal'], 'journal', 'article')
  end

end
