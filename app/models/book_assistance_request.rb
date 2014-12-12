class BookAssistanceRequest < AssistanceRequest
  validates :book_title, :book_year, :presence => true
  validates :notes, :presence => true, :if => Proc.new {|br| br.book_suggest}

  def self.fields
    fields = super
    fields + [:book_suggest]
  end

  def genre
    :book
  end

  def title
    book_title
  end

  def author
    book_author
  end

  def openurl
    generate_openurl(['book'], 'book', 'book')
  end

end
