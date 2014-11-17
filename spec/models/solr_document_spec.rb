# -*- encoding : utf-8 -*-
require 'rails_helper'
require 'openurl'

describe "SolrDocument" do

  it "registers its export formats" do
    document = SolrDocument.new
    Set.new(document.export_formats.keys).should be_superset(Set.new([:bib, :ris]))
  end

  let(:article) do
    SolrDocument.new({
      :format  => "article",
      :title_ts => "Are there true cosmopolitan sipunculan worms? A genetic variation study within Phascolosoma perlucens (Sipuncula, Phascolosomatidae)",
      :author_ts => ["Kawauchi, Gisele Y.", "Giribet, Gonzalo"],
      :pub_date_tis => "2010",
      :language_ss => "English",
      :issn_ss => ["00253162", "14321793"],
      :journal_title_ts => "Marine Biology",
      :publisher_ts => "Springer-Verlag",
      :doi_ss => "10.1007/s00227-010-1402-z",
      :journal_page_ssf => "1417-1431"
    })
  end

  let(:book) do
    SolrDocument.new({
      "publisher_ts" => ["Polyteknisk Forlag"],
      "member_id_ss" => ["316397882"],
      "title_ts" => ["Kemiske enhedsoperationer"],
      "source_ss" => ["alis"],
      "format" => "book",
      "pub_date_tis" => [2004],
      "journal_page_ssf" => ["597 sider"],
      "keywords_ts" => ["kemiske enhedsoperationer.", "lærebøger."],
      "keywords_facet" => ["kemiske enhedsoperationer.", "lærebøger."],
      "isbn_ss" => ["8750209418", "9788750209416"],
      "cluster_id_ss" => ["191135307"],
      "source_id_ss" => ["alis:000461671"],
      "author_ts" => ["Clement, Karsten H.,, et al."],
      "author_facet" => ["Clement, Karsten H.,, et al."],
      "source_type_ss" => ["other"]
    })
  end

  describe "#to_bibtex" do
    it "generates a BibTeX reference for an article" do
      ref = article.to_bibtex
      ref.title.should match "cosmopolitan sipunculan worms"
      ref.author.should match "Kawauchi"
      ref.author.should match "Giribet"
      ref.issn.should match "00253162"
      ref.year.should == 2010
    end

    it "generates a BibTeX reference for a book" do
      ref = book.to_bibtex
      ref.title.should eq "Kemiske enhedsoperationer"
    end
  end

  describe "#export_as_ris" do
    it "generates a RIS reference for an article" do
      ref = article.export_as_ris
      ref.should match "TI  - Are there true cosmopolitan sipunculan worms?"
      ref.should match "SP  - 1417"
      ref.should match "EP  - 1431"
    end
  end

  describe "#export_as_citation_txt" do
    it "generates a citation" do
      article.citation_styles.each do |style|
        citation = article.export_as_citation_txt(style)
        citation.should match /Cosmopolitan Sipunculan Worms/i
      end
    end
  end

  describe "#export_as_openurl_ctx_kev" do
    it "generates an OpenUrl for an article" do
      openurl = OpenURL::ContextObject.new_from_kev(article.export_as_openurl_ctx_kev)
      openurl.referent.format.should eq "journal"
      openurl.referent.metadata["genre"].should eq "article"
      openurl.referent.metadata["au"].should eq "Kawauchi, Gisele Y."
      openurl.referent.metadata["date"].should eq "2010"
      openurl.referent.metadata["atitle"].should match /Are there true cosmopolitan sipunculan worms/
      openurl.referent.metadata["jtitle"].should eq "Marine Biology"
      openurl.referent.identifiers.should include "urn:issn:00253162"
      openurl.referent.identifiers.should include "urn:issn:14321793"
      openurl.referent.identifiers.should include "info:doi/10.1007/s00227-010-1402-z"
      openurl.referent.metadata["doi"].should eq "10.1007/s00227-010-1402-z"
      openurl.referent.metadata["spage"].should eq "1417"
      openurl.referent.metadata["epage"].should eq "1431"
      openurl.referent.metadata["pub"].should eq "Springer-Verlag"
    end

    it "generates an OpenUrl for a book" do
      openurl = OpenURL::ContextObject.new_from_kev(book.export_as_openurl_ctx_kev)
      openurl.referent.format.should eq "book"
      openurl.referent.metadata["genre"].should eq "book"
      openurl.referent.metadata["pub"].should eq "Polyteknisk Forlag"
      openurl.referent.metadata["btitle"].should eq "Kemiske enhedsoperationer"
      openurl.referent.metadata["date"].should eq "2004"
      openurl.referent.metadata["isbn"].should eq "9788750209416"
      openurl.referent.identifiers.should include "urn:isbn:8750209418"
      openurl.referent.identifiers.should include "urn:isbn:9788750209416"
      openurl.referent.metadata["au"].should eq "Clement, Karsten H.,, et al."
      openurl.referent.private_data.should eq '{"id":"191135307","alis_id":"000461671"}'
    end

    it "sets the start or end pages even when pages element is not well formed" do
      openurl = OpenURL::ContextObject.new_from_kev(
        SolrDocument.new({
          'title_ts'=>['STREAMLINE CURVATURE COMPUTING PROCEDURES FOR FLUID-FLOW PROBLEMS'],
          'journal_issue_ssf'=>['4'],
          'issn_ss'=>['00220825', '2161945x'],
          'source_id_ss'=>['isi:A1967A075300004'],
          'journal_vol_ssf'=>['89'],
          'journal_title_ts'=>['JOURNAL OF ENGINEERING FOR POWER'],
          'format'=>'article',
          'language_ss'=>['English'],
          'pub_date_tis'=>[1967],
          'journal_page_ssf'=>['478-&'],
          'cluster_id_ss'=>['152427633'],
          'author_ts'=>['Novak, RA']
        }).export_as_openurl_ctx_kev)
      openurl.referent.metadata["spage"].should eq "478"
      openurl.referent.metadata["epage"].should be_nil

      openurl = OpenURL::ContextObject.new_from_kev(
        SolrDocument.new({
          'title_ts'=>['PEDESTRIAN FLOW CHARACTERISTICS'],
          'journal_issue_ssf'=>['9'],
          'issn_ss'=>['00410675'],
          'journal_vol_ssf'=>['39'],
          'journal_title_ts'=>['Traffic Eng'],
          'format'=>'article',
          'pub_date_tis'=>[1969],
          'journal_page_ssf'=>['30-3, 36'],
          'author_ts'=>['NAVIN FPD', 'WHEELER RJ']
        }).export_as_openurl_ctx_kev)
      openurl.referent.metadata["spage"].should eq "30"
      openurl.referent.metadata["epage"].should be_nil
    end
  end

  describe ".create_from_openURL" do

    let(:article) do
      SolrDocument.create_from_openURL(
        OpenURL::ContextObject.new_from_form_vars({
          "url_ver"     => "Z39.88-2004",
          "url_ctx_fmt" => "info:ofi/fmt:kev:mtx:ctx",
          "ctx_ver"     => "Z39.88-2004",
          "ctx_enc"     => "info:ofi/enc:UTF-8",
          "rft.genre"   => "article",
          "rft.atitle"  => "Are there true cosmopolitan sipunculan worms? A genetic variation study within Phascolosoma perlucens (Sipuncula, Phascolosomatidae)",
          "rft.au"      => "Kawauchi, Gisele Y.",
          "rft.jtitle"  => "MARINE BIOLOGY",
          "rft.volume"  => "157",
          "rft.issue"   => "7",
          "rft.spage"   => "1417",
          "rft.epage"   => "1431",
          "rft.date"    => "2010",
          "rft.issn"    => "14321793",
          "rft_val_fmt" => "info:ofi/fmt:kev:mtx:journal",
          "rft_id"      => ["urn:issn:00253162", "urn:issn:14321793", "info:doi/10.1007/s00227-010-1402-z"]
        }))
    end

    it "creates a valid Solr document for an article" do
      article["format"].should eq "article"
      article["title_ts"].first.should eq "Are there true cosmopolitan sipunculan worms? A genetic variation study within Phascolosoma perlucens (Sipuncula, Phascolosomatidae)"
      article["author_ts"].first.should eq "Kawauchi, Gisele Y."
      article["journal_title_ts"].first.should eq "MARINE BIOLOGY"
      article["journal_vol_ssf"].first.should eq "157"
      article["journal_issue_ssf"].first.should eq "7"
      article["journal_page_ssf"].first.should eq "1417-1431"
      article["pub_date_tis"].first.should eq "2010"
      article["doi_ss"].first.should eq "10.1007/s00227-010-1402-z"
      article["issn_ss"].should =~ ["00253162", "14321793"]
    end

    let(:book) do
      SolrDocument.create_from_openURL(
        OpenURL::ContextObject.new_from_form_vars({
          "url_ver" => "Z39.88-2004",
          "url_ctx_fmt" => "info:ofi/fmt:kev:mtx:ctx",
          "ctx_ver" => "Z39.88-2004",
          "ctx_enc" => "info:ofi/enc:UTF-8",
          "rft.genre" => "book",
          "rft.btitle" => "Advanced engineering mathematics",
          "rft.au" => ["Zill, Dennis G.", "Wright, Warren S."],
          "rft.date" => "2014",
          "rft.isbn" => "9781449679774",
          "rft_val_fmt" => "info:ofi/fmt:kev:mtx:book",
          "rft_id" => ["urn:isbn:9781449693022", "urn:isbn:9781449679774"]
        }))
    end

    it "creates a valid Solr document for a book" do
      book["format"].should eq "book"
      book["title_ts"].first.should eq "Advanced engineering mathematics"
      book["author_ts"].first.should eq "Zill, Dennis G."
      book["pub_date_tis"].first.should eq "2014"
      book["isbn_ss"].should =~ ["9781449693022", "9781449679774"]
    end

    let(:journal) do
      SolrDocument.create_from_openURL(
        OpenURL::ContextObject.new_from_form_vars({
          "url_ver" => "Z39.88-2004",
          "url_ctx_fmt" => "info:ofi/fmt:kev:mtx:ctx",
          "ctx_ver" => "Z39.88-2004",
          "ctx_enc" => "info:ofi/enc:UTF-8",
          "rft.genre" => "journal",
          "rft.jtitle" => "Accident analysis and prevention",
          "rft.issn" => "18792057",
          "rft_val_fmt" => "info:ofi/fmt:kev:mtx:journal",
          "rft_id" => ["urn:issn:00014575", "urn:issn:18792057"]
        }))
    end

    it "creates a valid Solr document for a journal" do
      journal["format"].should eq "journal"
      journal["title_ts"].first.should eq "Accident analysis and prevention"
      journal["journal_title_ts"].first.should eq "Accident analysis and prevention"
      journal["issn_ss"].should =~ ["00014575", "18792057"]
    end
  end
end
