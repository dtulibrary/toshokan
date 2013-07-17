# -*- encoding : utf-8 -*-
require 'citeproc'
require 'openurl'

class SolrDocument 
  include Configured
  include Blacklight::Solr::Document

  self.unique_key = SolrDocument.document_id

  SolrDocument.use_extension(References)

  attr_reader :citation_styles

  def initialize *args
    super
    @citation_styles = [:mla, :apa, :'chicago-author-date']
  end  

  def id
    id = self[self.class.unique_key]
    id.kind_of?(Array) ? id.first : id
  end
  
  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Solr::Document::DublinCore)    
  field_semantics.merge!(    
                         # DC, BibTeX, Ris 
                         :title => "title_ts",
                         :language => "language_ss",
                         :format => "format",
                         :publisher => "publisher_ts",
                         # DC
                         :subject => "keywords_ts",
                         :description => "abstract_ts", 
                         :creator => "author_ts",
                         :date => "pub_date_ti",
                         :identifier => "doi_s",
                         # BibTeX, Ris
                         :author => "author_ts",
                         :editor => "editor_ts",
                         :journal => "journal_title_ts",
                         :volume => "journal_vol_ssf",
                         :number => "journal_issue_ssf",
                         :pages => "journal_page_ssf",
                         :year => "pub_date_tis",
                         :issn => "issn_ss",
                         :isbn => "isbn_ss",
                         :abstract => "abstract_ts",
                         :doi => "doi_ss",
                         :keywords => "keywords_ts",
                         # COinS
                         :open_url => "open_url_sf"
                         )

  def export_as_openurl_ctx_kev(format = nil)
    @context_object ||= create_openurl
    @context_object.kev     
  end

  def export_as_citation_txt(style_name)
    CiteProc.process self.to_bibtex.to_citeproc, :style => style_name.to_sym  
  end

  def has_citation_style(style)
    @citation_styles.include? style.to_sym
  end

  private

  def create_openurl    
    @context_object = OpenURL::ContextObject.new
    format = self[:format]
    genre  = self[:format]
    format = "journal" if format == "article"        
    @context_object.referent.set_format(format)
    @context_object.referent.set_metadata('genre', genre)    
    self.to_semantic_values.each do |field, value|
      case field
      when :title
        key = "atitle"        
        if genre == "book"
          key = "btitle" 
        elsif genre == "journal"
          key = "jtitle" 
        end
        @context_object.referent.set_metadata(key, value.first)
      when :journal
        @context_object.referent.set_metadata("jtitle", value.first)
      when :author
        @context_object.referent.set_metadata("au", value.first)
      when :volume
        @context_object.referent.set_metadata("volume", value.first)
      when :issue
        @context_object.referent.set_metadata("issue", value.first)
      when :pages
        if value.first.to_s =~ /^\s*(\d+)\s*-+\s*(\d+)\s*$/
          @context_object.referent.set_metadata("spage", "#{$1}")
          @context_object.referent.set_metadata("epage", "#{$2}")
        end
      when :year 
        @context_object.referent.set_metadata("date", value.first.to_s)        
      when :doi
        @context_object.referent.add_identifier("info:doi/#{value.first}")
      end
      if [:issn, :isbn].include?(field)
        value.each do |v|
          @context_object.referent.set_metadata(field.to_s, v)
          #@context_object.referent.add_identifier("urn:#{field}:#{v}")
        end
      end
    end
    @context_object
  end
end