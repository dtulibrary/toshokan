# -*- encoding : utf-8 -*-
require 'citeproc'

class SolrDocument 

  include Blacklight::Solr::Document

  SolrDocument.use_extension(References)

  attr_reader :citation_styles

  def initialize *args
    super
    @citation_styles = [:mla, :apa, :'chicago-author-date']
  end  
  
  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Solr::Document::DublinCore)    
  field_semantics.merge!(    
                         # DC, BibTeX, Ris 
                         :title => "title_t",
                         :language => "language_t",
                         :format => "format",
                         :publisher => "publisher_t",
                         # DC
                         :subject => "keywords_t",
                         :description => "abstract_t", 
                         :creator => "author_name_t",
                         :date => "pub_date",
                         :identifier => "doi_t",
                         # BibTeX, Ris
                         :author => "author_name_t",
                         :editor => "editor_name_t",
                         :journal => "journal_title_t",
                         :volume => "journal_vol_t",
                         :number => "journal_issue_t",
                         :pages => "journal_page_t",
                         :year => "pub_date",
                         :issn => "issn_t",
                         :isbn => "isbn_t",
                         :abstract => "abstract_t",
                         :doi => "doi_t",
                         :keywords => "keywords_t",
                         # COinS
                         :open_url => "open_url"
                         )

  def export_as_openurl_ctx_kev(format = nil)
    self.to_semantic_values.has_key?(:open_url) ? self.to_semantic_values[:open_url].first : ""
  end

  def export_as_citation_txt(style_name)
    CiteProc.process self.to_bibtex.to_citeproc, :style => style_name.to_sym  
  end

  def has_citation_style(style)
    @citation_styles.include? style.to_sym
  end

end
