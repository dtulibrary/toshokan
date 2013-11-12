class ConferenceArticleAssistanceRequest < AssistanceRequest
  validates :article_title, :conference_pages, :conference_title, :conference_year, :presence => true
end
