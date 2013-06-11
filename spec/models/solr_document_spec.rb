# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'openurl'

describe "SolrDocument" do

  before(:all) do

    art_data = {
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
    }
    @art = SolrDocument.new(art_data)
  end

  it "registers its export formats" do
    document = SolrDocument.new
    Set.new(document.export_formats.keys).should be_superset(Set.new([:bib, :ris]))    
  end

  it "generates a BibTeX reference" do
    ref = @art.to_bibtex
    ref.title.should match "cosmopolitan sipunculan worms"
    ref.author.should match "Kawauchi"
    ref.author.should match "Giribet"
    ref.issn.should match "00253162"
    ref.year.should == 2010
  end

  it "generates a RIS reference" do
    ref = @art.export_as_ris
    ref.should match "TI  - Are there true cosmopolitan sipunculan worms?"
    ref.should match "SP  - 1417"
    ref.should match "EP  - 1431"
  end

  it "generates a citation" do
    citation = @art.export_as_citation_txt("mla")
    citation.should match "Cosmopolitan Sipunculan Worms"
  end

  it "generates an OpenUrl" do
    openurl = OpenURL::ContextObject.new_from_kev(@art.export_as_openurl_ctx_kev)
    openurl.referent.metadata["genre"].should match "article"
    openurl.referent.identifier.should match /doi/
  end

end
