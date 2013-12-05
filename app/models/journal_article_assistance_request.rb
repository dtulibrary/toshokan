class JournalArticleAssistanceRequest < AssistanceRequest
  validates :article_title, :journal_title, :journal_volume, :journal_issue, :journal_year, :journal_pages, :presence => true
end
