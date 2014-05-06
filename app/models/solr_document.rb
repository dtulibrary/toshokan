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
                         :date => "pub_date_tis",
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
                         # OpenURL
                         :genre => "format",
                         :atitle => "title_ts",
                         :btitle => "title_ts",
                         :au => "author_ts",
                         :spage => "journal_page_ssf",
                         :jtitle => "journal_title_ts",
                         :volume => "journal_vol_ssf",
                         :issue => "journal_issue_ssf",
                         :date => "pub_date_tis",
                         # issn, isbn shared with BibTex & Ris
                         # Other
                         :affiliation => "affiliation_ts"
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

  # used for synthesizing a record from a reference
  def self.create_from_openURL(context_object)

    solr_doc = {}

    solr_doc[self.field_semantics[:format]] = context_object.referent.format
    if context_object.referent.format == "journal" && context_object.referent.metadata.has_key?("atitle")
      solr_doc[self.field_semantics[:format]] = "article"
    end

    context_object.referent.metadata.each do |metadata|
      if self.field_semantics.has_key?(metadata.first.to_sym)
        if metadata.first.to_sym == :genre
          # match to subformats when available
        # page element
        elsif metadata.first.to_sym == :spage
          page_info = metadata.last
          unless context_object.referent.metadata["epage"].nil?
            page_info += "-#{context_object.referent.metadata['epage']}"
          end
          solr_doc[self.field_semantics[metadata.first.to_sym]] = [page_info]
        else
          solr_doc[self.field_semantics[metadata.first.to_sym]] = [metadata.last]
        end
      end
    end

    # set other author elements
    if context_object.referent.authors && context_object.referent.authors.length > 0
      solr_doc[self.field_semantics[:author]] = []
      context_object.referent.authors.each do |author|
        solr_doc[self.field_semantics[:author]] << author.au if author.au
        if author.aulast
          au = author.aulast
          if author.aufirst
            au = "#{au}, #{author.aufirst}"
          elsif author.auinit
            au = "#{au}, #{author.auinit}"
          end
          solr_doc[self.field_semantics[:author]] << au
        end
      end
    end

    # set title for journals
    if solr_doc["format"] && solr_doc["format"] == "journal" && solr_doc["journal_title_ts"]
      solr_doc["title_ts"] = solr_doc["journal_title_ts"]
    end

    # set additional ids which are not included in metatdata
    unless context_object.referent.identifiers.nil?
      context_object.referent.identifiers.each do |id|
        if m = id.match(/(urn|info):([^:\/]*)[:\/](.*)/)
          ou_field = m[2].to_sym
          if self.field_semantics.has_key?(ou_field) && !m[3].blank?
            solr_doc[self.field_semantics[ou_field]] = [] if solr_doc[self.field_semantics[ou_field]].nil?
            solr_doc[self.field_semantics[ou_field]] << m[3] unless solr_doc[self.field_semantics[ou_field]].include?(m[3])
          end
        end
      end
    end

    create_synthesized_record(solr_doc)
  end

  def self.create_synthesized_record(data)
    # set fake id
    data[:id] = 0

    doc = SolrDocument.new(data)

    # override more_like_this which depends on a solr response being set
    doc.define_singleton_method(:more_like_this) { [] }

    doc
  end

  private

  def create_openurl
    # Note that multiple values for a metadata key (i.e. rft.au) is currently not supported
    # (not supported by the OpenURL gem)

    @context_object = OpenURL::ContextObject.new
    @context_object.referrer.add_identifier('info:sid/findit.dtu.dk')
    format = self[:format]
    genre = format
    format = "journal" if format == "article"
    @context_object.referent.set_format(format)
    @context_object.referent.set_metadata('genre', genre)

    custom_data = {:id => self.id}
    if show_feature?(:alis) && self[:source_ss] && self[:source_ss].include?("alis")
      self[:source_id_ss].each do |source_id|
        if m = /alis:(\d*)/.match(source_id)
          custom_data[:alis_id] = m[1]
          break
        end
      end
    end
    @context_object.referent.set_private_data(custom_data.to_json)

    self.to_semantic_values.each do |field, value|
      case field
      when :title
        key = "atitle"
        if format == "book"
          key = "btitle"
        elsif format == "journal" && genre != "article"
          key = "jtitle"
        end
        @context_object.referent.set_metadata(key, value.first)
      when :journal
        @context_object.referent.set_metadata("jtitle", value.first)
      when :author
        @context_object.referent.set_metadata("au", value.first)
      when :volume
        @context_object.referent.set_metadata("volume", value.first)
      when :number
        @context_object.referent.set_metadata("issue", value.first)
      when :publisher
        @context_object.referent.set_metadata("pub", value.first)
      when :pages
        if value.first.to_s =~ /^\s*(\d+)\s*-+\s*(\d+)\s*$/
          @context_object.referent.set_metadata("spage", "#{$1}")
          @context_object.referent.set_metadata("epage", "#{$2}")
        end
      when :year
        @context_object.referent.set_metadata("date", value.first.to_s)
      when :doi
        @context_object.referent.set_metadata("doi", "#{value.first}")
        @context_object.referent.add_identifier("info:doi/#{value.first}")
      end
      if [:issn, :isbn].include?(field)
        value.each do |v|
          @context_object.referent.set_metadata(field.to_s, v)
          @context_object.referent.add_identifier("urn:#{field}:#{v}")
        end
      end
    end
    @context_object
  end
end