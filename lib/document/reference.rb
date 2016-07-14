require 'bibtex'

module Reference

  def self.extended(document)
    document.will_export_as(:bib, "text/x-bibtex")
    document.will_export_as(:ris, "application/x-Research-Info-Systems")
  end

  BIBTEX_FIELD_NAMES = [:title, :author, :inventor, :language, :format, :editor, :journal, :volume, :number, :pages, :year,
    :issn, :isbn, :abstract, :publisher, :doi]
  
  def export_as_bib
    self.to_bibtex.to_s
  end

  def export_as_ris
    self.to_ris
  end

  def parse_name_to_bibtex(name)
    result = nil

    begin
      result = BibTeX::Name.parse(name)
      raise Exception.new("Name is null") if result.nil?
    rescue Exception => e
      Rails.logger.info "Could not parse name when converting to BibTeX: #{e.inspect}"
      # Name is not well formed, we'll just add it as is
      result = BibTeX::Name.new({:last => name})
    end

    result
  end

  def to_bibtex
    bib_doc = BibTeX::Entry.new
    bib_doc.type = self.to_semantic_values[:format].first

    names = BibTeX::Names.new

    self.to_semantic_values.select { |field, values| BIBTEX_FIELD_NAMES.include? field.to_sym }.each do |field,values|
      case(field)   
      when :journal
        bib_doc.add(field.to_sym, values.first) unless values.first.nil?
      when :format    
      when :author
        values.collect { |v| parse_name_to_bibtex(v) }.each { |n| names.add(n) }
      when :inventor
        values.collect { |v| parse_name_to_bibtex(v) }.each { |n| names.add(n) }
      when :abstract
        bib_doc.add(field.to_sym, values.first)
      else
        bib_doc.add(field.to_sym, values.join(", "))  
      end
    end

    bib_doc.add(:author, names)

    bib_doc
  end

  RIS_FIELD_NAMES = {
    :title => "TI",
    :author => "AU",
    :language => "LA",
    :editor => "A2",
    :journal => "JF",
    :volume => "VL",
    :number => "IS",
    :year => "PY",
    :issn => "SN",
    :isbn => "SN",
    :abstract => "AB",
    :publisher => "PB",
    :doi => "DO",
    :keywords => "KW"
  }

  def to_ris(options = {})
    # keyword must be followed by two spaces in order to work with reference manager
    content = "TY  - #{ris_type}\n"

    to_bibtex.fields.each do |field, value|
      case(field)
      when :pages
        if value.to_s =~ /^\s*(\d+)\s*-+\s*(\d+)\s*$/
          content << "SP  - #{$1}\n"
          content << "EP  - #{$2}\n"
        end
      else
        if RIS_FIELD_NAMES.include? field
          if value.kind_of? Enumerable
            value.each do |v|
              content << "#{RIS_FIELD_NAMES[field]}  - #{v}\n"
            end
          else
            content << "#{RIS_FIELD_NAMES[field]}  - #{value}\n"
          end
        end
      end
    end

    content << "ER  -"
    content
  end

  def subtype
    (self["subformat_s"] || "").to_sym
  end

  def ris_type
    return 'CPAPER' if subtype.eql?(:conference_paper)
    return 'CHAP' if subtype.eql?(:bookchapter)
    return 'PAT' if subtype.eql?(:patent)

    return case to_bibtex.type
      when :article
        'JOUR'
      when :book
        'BOOK'
      when :journal
        'JFULL'
      end
  end
end
