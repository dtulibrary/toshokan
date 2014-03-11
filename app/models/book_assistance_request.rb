class BookAssistanceRequest < AssistanceRequest
  validates :book_title, :book_year, :presence => true
  validates :notes, :presence => true, :if => Proc.new {|br| br.book_suggest}

  def genre
    :book
  end

  def title
    book_title
  end

  def author
    book_author
  end
end
