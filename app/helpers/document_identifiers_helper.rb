module DocumentIdentifiersHelper

  def render_doi_link args
    doi = args[:document][args[:field]].first
    link_to doi, "http://dx.doi.org/#{doi}"
  end

  def render_issn args, separator = ', '
    args[:document][args[:field]].collect {|issn| issn.sub /^(.{4})/, '\1-'}.join(separator).html_safe
  end

  def render_isbn args, separator = ', '
    args[:document][args[:field]].collect {|isbn| (Lisbn.new(isbn).parts || [isbn]).join '-'}.join(separator).html_safe
  end

  def render_issn_index args
    render_issn args
  end

  def render_issn_show args
    render_issn args, '<br>'
  end

  def render_isbn_index args
    render_isbn args
  end

  def render_isbn_show args
    render_isbn args, '<br>'
  end

end