class BookAssistanceRequest < AssistanceRequest
  validates :book_title, :book_year, :presence => true
  validates :notes, :presence => true, :if => Proc.new {|br| br.book_suggest}
end
