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
    self.to_semantic_values.has_key?(:open_url) ? self.to_semantic_values[:open_url].first : ""
  end

  def export_as_citation_txt(style_name)
    CiteProc.process self.to_bibtex.to_citeproc, :style => style_name.to_sym  
  end

  def has_citation_style(style)
    @citation_styles.include? style.to_sym
  end

end
