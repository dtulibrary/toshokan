require 'bibtex'

module Reference

  def self.extended(document)
    document.will_export_as(:bib, "text/x-bibtex")
    document.will_export_as(:ris, "application/x-Research-Info-Systems")
  end

  BIBTEX_FIELD_NAMES = [:title, :author, :language, :format, :editor, :journal, :volume, :number, :pages, :year, 
    :issn, :isbn, :abstract, :publisher, :doi]
  
  def export_as_bib
    self.to_bibtex.to_s
  end

  def export_as_ris
    self.to_bibtex.to_ris
  end

  def to_bibtex
    bib_doc = Reference::Entry.new
    bib_doc.type = self.to_semantic_values[:format].first
    bib_doc.subtype = self["subformat_s"]
    self.to_semantic_values.select { |field, values| BIBTEX_FIELD_NAMES.include? field.to_sym }.each do |field,values|
      case(field)   
      when :journal
        bib_doc.add(field.to_sym, values.first) unless values.first.nil?
      when :format    
      when :author
        names = BibTeX::Names.new
        values.each do |v|
          begin
            names.add(BibTeX::Name.parse(v))
          rescue Exception => e 
            Rails.logger.info "Could not parse name when converting to BibTeX: #{e.inspect}"
            # Name is not well formed, we'll just add it as is
            names.add(BibTeX::Name.new({:last => v}))
          end 
        end
        bib_doc.add(field.to_sym, names)
      when :abstract
        bib_doc.add(field.to_sym, values.first)
      else
        bib_doc.add(field.to_sym, values.join(", "))  
      end
    end
    bib_doc
  end

  class Entry < BibTeX::Entry

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

    def ris_type
      return 'CPAPER' if subtype.to_sym.eql?(:conference_paper)
      return 'CHAP' if subtype.to_sym.eql?(:bookchapter)
      return 'PAT' if subtype.to_sym.eql?(:patent)

      return case type
        when :article
          'JOUR'
        when :book
          'BOOK'
        when :journal
          'JFULL'
        when :thesis
          'THES'
        else
          'GEN'
        end
    end

    def to_ris(options = {})
      # keyword must be followed by two spaces in order to work with reference manager
      content = "TY  - #{ris_type}\n"

      fields.each do |field, value|
        case(field)
        when :pages
          if get(:pages).to_s =~ /^\s*(\d+)\s*-+\s*(\d+)\s*$/
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
  end
end
