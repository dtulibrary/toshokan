class ReportAssistanceRequest < AssistanceRequest
  validates :report_title, :host_year, :presence => true

  def genre
    :report
  end

  def title
    report_title
  end

  def author
    thesis_author || 'unspecified'
  end

  def openurl
    generate_openurl(['report', 'host'], 'book', 'report')
  end

end
