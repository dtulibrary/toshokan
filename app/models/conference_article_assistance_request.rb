class ConferenceArticleAssistanceRequest < AssistanceRequest
  validates :article_title, :proceedings_pages, :conference_title, :conference_year, :presence => true
end
