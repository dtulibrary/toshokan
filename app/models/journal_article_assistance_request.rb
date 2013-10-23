class JournalArticleAssistanceRequest < AssistanceRequest
  validates :article_title, :journal_title, :journal_volume, :journal_issue, :journal_year, :journal_pages, :presence => true

=begin
  attr_accessible(:article_title, :article_author, :article_doi, 
                  :journal_title, :journal_issn, :journal_volume, :journal_issue, :journal_year, :journal_pages,
                  :notes)
=end
end
