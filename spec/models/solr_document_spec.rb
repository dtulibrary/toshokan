# -*- encoding : utf-8 -*-
require 'spec_helper'
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
      'publisher_ts'=>['Polyteknisk Forlag'],
      'title_ts'=>['Kemiske enhedsoperationer'],
      'format'=>'book',
      'alis_key_ssf'=>['000461671'],
      'pub_date_tis'=>[2004],
      'journal_page_ssf'=>['597 sider'],
      'isbn_ss'=>['8750209418',
        '9788750209416'],
      'keywords_ts'=>['kemiske enhedsoperationer.',
        'lærebøger.'],
      'keywords_facet'=>['kemiske enhedsoperationer.',
        'lærebøger.'],
      'author_ts'=>['Clement, Karsten H.,, et al.'],
      'author_facet'=>['Clement, Karsten H.,, et al.']
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
      citation = article.export_as_citation_txt("mla")
      citation.should match "Cosmopolitan Sipunculan Worms"
    end
  end

  describe "#export_as_openurl_ctx_kev" do
    it "generates an OpenUrl" do
      openurl = OpenURL::ContextObject.new_from_kev(article.export_as_openurl_ctx_kev)
      openurl.referent.metadata["genre"].should match "article"
      openurl.referent.metadata["jtitle"].should match "Marine Biology"
      openurl.referent.identifiers.first.should match /issn/
      openurl.referent.identifiers.last.should match /doi/
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
          "rft.doi"     => "10.1007/s00227-010-1402-z",
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
