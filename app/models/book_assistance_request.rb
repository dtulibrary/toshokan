class BookAssistanceRequest < AssistanceRequest
  validates :book_title, :book_year, :presence => true
end
