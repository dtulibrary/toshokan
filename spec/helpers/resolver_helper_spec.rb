require "spec_helper"

describe ResolverHelper do

  describe "#to_open_url" do

    it "returns nil if it can't identify an open url from params" do
      helper.to_open_url({"foo" => "bar"}).should be nil
    end

    it "accepts a chemical abstracts url" do
      chem_abs_url = "sid=CAS:CAPLUS&issn=0365-9496&volume=14&coden=BDCGAS&genre=article&spage=1643&title=Berichte der Deutschen Chemischen Gesellschaft&stitle=Ber.&atitle=Barbituric acid&aulast=Guthzeit&aufirst=M&pid=<authfull>Guthzeit, M.</authfull><source>Berichte der Deutschen Chemischen Gesellschaft 14, 1643-5. From: J. Chem. Soc., Abstr. 40, 1033 1881. CODEN:BDCGAS ISSN:0365-9496.</source>"
      ou = helper.to_open_url(Rack::Utils.parse_query(chem_abs_url))
      ou.referent.format.should eq "journal"
      ou.referent.metadata["genre"].should eq "article"
      ou.referent.metadata['issn'].should eq "0365-9496"
      ou.referent.metadata['volume'].should eq "14"
      ou.referent.metadata['spage'].should eq "1643"
      ou.referent.metadata['atitle'].should eq "Barbituric acid"
      ou.referent.metadata['jtitle'].should eq "Berichte der Deutschen Chemischen Gesellschaft"
      ou.referent.metadata['stitle'].should eq "Ber."
      ou.referent.metadata['title'].should eq nil
      ou.referent.metadata['aulast'].should eq "Guthzeit"
      ou.referent.metadata['aufirst'].should eq "M"
    end

    it "accepts an isi url " do
      isi_url = "url_ver=Z39.88-2004&url_ctx_fmt=info:ofi/fmt:kev:mtx:ctx&rft_val_fmt=info:ofi/fmt:kev:mtx:book&rft.artnum=UNSP%20858802&rft.atitle=Promising%20new%20wavelengths%20for%20multi-photon%20fluorescence%20microscopy%3A%20thinking%20outside%20the%20Ti%3ASapphire%20box&rft.aufirst=Greg&rft.aulast=Norris&rft.btitle=MULTIPHOTON%20MICROSCOPY%20IN%20THE%20BIOMEDICAL%20SCIENCES%20XIII&rft.date=2013&rft.genre=proceeding&rft.isbn=978-0-8194-9357-6&rft.issn=0277-786X&rft.place=BELLINGHAM&rft.pub=SPIE-INT%20SOC%20OPTICAL%20ENGINEERING&rft.series=Proceedings%20of%20SPIE&rft.tpages=12&rft.volume=8588&rfr_id=info:sid/www.isinet.com:WoK:WOS&rft.au=Amor%2C%20Rumelo&rft.au=Dempster%2C%20John&rft.au=Amos%2C%20William%20B%2E&rft.au=McConnell%2C%20Gail&rft_id=info:doi/10%2E1117%2F12%2E2008189"
      ou = helper.to_open_url(Rack::Utils.parse_query(isi_url))
      ou.referent.format.should eq "book"
      ou.referent.metadata["genre"].should eq "proceeding"
      ou.referrer.identifiers.should include "info:sid/www.isinet.com:WoK:WOS"
      ou.referent.metadata['btitle'].should eq "MULTIPHOTON MICROSCOPY IN THE BIOMEDICAL SCIENCES XIII"
      ou.referent.metadata['atitle'].should eq "Promising new wavelengths for multi-photon fluorescence microscopy: thinking outside the Ti:Sapphire box"
      ou.referent.metadata['aulast'].should eq "Norris"
      ou.referent.metadata['aufirst'].should eq "Greg"
      ou.referent.metadata['date'].should eq "2013"
      ou.referent.metadata['isbn'].should eq "978-0-8194-9357-6"
      ou.referent.metadata['issn'].should eq "0277-786X"
      ou.referent.metadata['volume'].should eq "8588"
      ou.referent.metadata['place'].should eq "BELLINGHAM"
      ou.referent.metadata['pub'].should eq "SPIE-INT SOC OPTICAL ENGINEERING"
      ou.referent.metadata['series'].should eq "Proceedings of SPIE"
      ou.referent.metadata['tpages'].should eq "12" # not part of standard, but we'll keep it
      ou.referent.metadata['au'].should eq "Amor, Rumelo"
      ou.referent.authors.length.should eq 5
      ou.referent.identifiers.should include "info:doi/10.1117/12.2008189"
    end

    it "accepts a short PubMed url" do
      pubmed_url = "sid=Entrez:PubMed&id=pmid:12217522"
      ou = helper.to_open_url(Rack::Utils.parse_query(pubmed_url))
      ou.referrer.identifiers.should include "info:sid/Entrez:PubMed"
      ou.referent.identifiers.first.should eq "info:pmid/12217522"
    end

    it "accepts a Google Scholar url" do
      scholar_url = "sid=google&auinit=K&aulast=Li&atitle=Performance+analysis+of+power-aware+task+scheduling+algorithms+on+multiprocessor+computers+with+dynamic+voltage+and+speed&id=doi:10.1109/TPDS.2008.122&title=IEEE+Transactions+on+Parallel+and+Distributed+Systems&volume=19&issue=11&date=2008&spage=1484&issn=1045-9219"
      ou = helper.to_open_url(Rack::Utils.parse_query(scholar_url))
      ou.referrer.identifiers.first.should eq "info:sid/google"
      ou.referent.metadata["jtitle"].should eq "IEEE Transactions on Parallel and Distributed Systems"
      ou.referent.metadata["atitle"].should eq "Performance analysis of power-aware task scheduling algorithms on multiprocessor computers with dynamic voltage and speed"
      ou.referent.metadata["title"].should be nil
      ou.referent.metadata["auinit"].should eq "K"
      ou.referent.metadata["aulast"].should eq "Li"
      ou.referent.authors.length.should be 1
      ou.referent.metadata["volume"].should eq "19"
      ou.referent.metadata["issue"].should eq "11"
      ou.referent.metadata["date"].should eq "2008"
      ou.referent.metadata["spage"].should eq "1484"
      ou.referent.metadata["issn"].should eq "1045-9219"
      ou.referent.identifiers.first.should eq "info:doi/10.1109/TPDS.2008.122"
    end

    it "accepts a Google Scholar book url" do
      scholar_url = "sid=google&auinit=NJ&aulast=Gimsing&title=Analysis+of+Erection+Procedures+for+Bridges+with+Combined+Cable+Systems:+Cable+Net+Bridge+Concept&genre=book&date=1980"
      ou = helper.to_open_url(Rack::Utils.parse_query(scholar_url))
      ou.referrer.identifiers.first.should eq "info:sid/google"
      ou.referent.format.should eq "book"
      ou.referent.metadata["genre"].should eq "book"
      ou.referent.metadata["date"].should eq "1980"
      ou.referent.metadata["btitle"].should eq "Analysis of Erection Procedures for Bridges with Combined Cable Systems: Cable Net Bridge Concept"
      ou.referent.metadata["auinit"].should eq "NJ"
      ou.referent.metadata["aulast"].should eq "Gimsing"
    end

    it "accepts a Scopus url" do
      scopus_url = "sid=Elsevier:Scopus&_service_type=getFullTxt&issn=09594388&isbn=&volume=23&issue=1&spage=43&epage=51&pages=43-51&artnum=&date=2013&id=doi:10.1016%252fj.conb.2012.11.006&title=Current+Opinion+in+Neurobiology&atitle=Decoding+the+genetics+of+speech+and+language&aufirst=S.A.&auinit=S.A.&auinit1=S&aulast=Graham"
      ou = helper.to_open_url(Rack::Utils.parse_query(scopus_url))
      ou.referrer.identifiers.first.should eq "info:sid/Elsevier:Scopus"
      ou.referent.metadata["genre"].should eq "article"
      ou.referent.metadata["date"].should eq "2013"
      ou.referent.metadata["issn"].should eq "09594388"
      ou.referent.metadata.should_not include ("isbn")
      ou.referent.metadata["volume"].should eq "23"
      ou.referent.metadata["issue"].should eq "1"
      ou.referent.metadata["spage"].should eq "43"
      ou.referent.metadata["epage"].should eq "51"
      ou.referent.metadata["pages"].should eq "43-51"
      ou.referent.metadata["date"].should eq "2013"
      ou.referent.identifiers.first.should include "info:doi/10.1016%2fj.conb.2012.11.006" # double encoding is handled elsewhere
      ou.referent.metadata["jtitle"].should eq "Current Opinion in Neurobiology"
      ou.referent.metadata["atitle"].should eq "Decoding the genetics of speech and language"
      ou.referent.metadata["aufirst"].should eq "S.A."
      ou.referent.metadata["auinit"].should eq "S.A."
      ou.referent.metadata["auinit1"].should eq "S"
      ou.referent.metadata["aulast"].should eq "Graham"
      ou.referent.authors.length.should be 1
    end

    it "accepts a Proquest url" do
      proquest_url = "url_ver=Z39.88-2004&rft_val_fmt=info:ofi/fmt:kev:mtx:book&genre=report&sid=ProQ:Aquatic+Science+%2526+Fisheries+Abstracts+%2528ASFA%2529+1%253A+Biological+Sciences+%2526+Living+Resources&atitle=&title=Experiments+in+freezing+of+shrimps.+The+effects+of+vacuum-packing+and+storage+with+use+of+carbon+dioxide+gas.&issn=0078186X&date=1961-01-01&volume=&issue=&spage=10&au=Karsti%252C+O%253BHakvaag%252C+D&isbn=&jtitle=&btitle=Experiments+in+freezing+of+shrimps.+The+effects+of+vacuum-packing+and+storage+with+use+of+carbon+dioxide+gas.&rft_id=info:eric/"
      ou = helper.to_open_url(Rack::Utils.parse_query(proquest_url))
      ou.referent.format.should eq "book"
      ou.referent.metadata["genre"].should eq "report"
      ou.referrer.identifiers.first.should eq "info:sid/ProQ:Aquatic Science %26 Fisheries Abstracts %28ASFA%29 1%3A Biological Sciences %26 Living Resources" # double encoding is handled elsewhere
      ou.referent.metadata["date"].should eq "1961"
      ou.referent.metadata["btitle"].should eq "Experiments in freezing of shrimps. The effects of vacuum-packing and storage with use of carbon dioxide gas."
      ou.referent.metadata["issn"].should eq "0078186X"
      ou.referent.metadata["spage"].should eq "10"
      ou.referent.metadata["au"].should eq "Karsti%2C O%3BHakvaag%2C D"
      ou.referent.metadata.length.should be 7
    end

    it "accepts another Proquest url" do
      proquest_url = "url_ver=Z39.88-2004&rft_val_fmt=info:ofi/fmt:kev:mtx:journal&genre=article&sid=ProQ:ProQ%253Aasfabiological&atitle=Sympatric+occurrence+of+living+Nautilus+%2528N.+pompilius+and+N.+stenomphalaus+%2529+on+the+Great+Barrier+Reef%252C+Australia.&title=Nautilus&issn=00281344&date=1988-01-01&volume=102&issue=1&spage=188&au=Saunders%252C+W+B%253BWard%252C+P+D&isbn=&jtitle=Nautilus&btitle=&rft_id=info:eric/"
      ou = helper.to_open_url(Rack::Utils.parse_query(proquest_url))
      ou.referent.format.should eq "journal"
      ou.referent.metadata["genre"].should eq "article"
      ou.referent.metadata["atitle"].should eq "Sympatric occurrence of living Nautilus %28N. pompilius and N. stenomphalaus %29 on the Great Barrier Reef%2C Australia." # double encoding is handled elsewhere
      ou.referent.metadata["jtitle"].should eq "Nautilus"
      ou.referent.metadata["date"].should eq "1988"
      ou.referent.metadata["issn"].should eq "00281344"
      ou.referent.metadata["volume"].should eq "102"
      ou.referent.metadata["issue"].should eq "1"
      ou.referent.metadata["spage"].should eq "188"
      ou.referent.metadata["au"].should eq "Saunders%2C W B%3BWard%2C P D"
    end

    it "accepts a Primo url" do
      primo_url = "ctx_enc=UTF-8&ctx_ver=Z39.88-2004&rfr_id=primo.exlibrisgroup.com%3Aprimo3-Article-gale_ofa&svc_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Asch_svc&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&url_ver=Z39.88-2004&rft.genre=article&rft.atitle=Management%20science%202009%20Report.%28Letter%20from%20the%20Editor%29%28Report%29&rft.jtitle=Management%20science&rft.stitle=MANAGE%20SCI&rft.stitle=MANAG%20SCI&rft.title=Management%20science&rft.au=Cachon%2C%20Gerard%20P&rft.aulast=Cachon&rft.aufirst=Gerard&rft.auinit=G%20P&rft.date=20100101&rft.pub=INFORMS&rft.place=%5BLinthicum%2C%20Md.%5D&rft.issn=0025-1909&rft.eissn=1526-5501&rft.coden=MSCIAM&rft.volume=56&rft.issue=1&rft.spage=2&rft_id=doi%3A&rft_id=oai%3A%3E&rft_dat=%3Cgale_ofa%3E219382786%3C%2Fgale_ofa%3E%3Cgrp_id%3E7617128399622374774%3C%2Fgrp_id%3E%3Coa%3E%3C%2Foa%3E&req.language=eng"
      ou = helper.to_open_url(Rack::Utils.parse_query(primo_url))
      ou.referent.format.should eq "journal"
      ou.referent.metadata["genre"].should eq "article"
      ou.referent.metadata["atitle"].should eq "Management science 2009 Report.(Letter from the Editor)(Report)"
      ou.referent.metadata["jtitle"].should eq "Management science"
      ou.referent.metadata["stitle"].should eq "MANAGE SCI"
      ou.referent.metadata["title"].should be nil
      ou.referent.metadata["au"].should eq "Cachon, Gerard P"
      ou.referent.metadata["aulast"].should eq "Cachon"
      ou.referent.metadata["aufirst"].should eq "Gerard"
      ou.referent.metadata["auinit"].should eq "G P"
      ou.referent.metadata["date"].should eq "2010"
      ou.referent.metadata["pub"].should eq "INFORMS"
      ou.referent.metadata["place"].should eq "[Linthicum, Md.]"
      ou.referent.metadata["issn"].should eq "0025-1909"
      ou.referent.metadata["eissn"].should eq "1526-5501"
      ou.referent.metadata["coden"].should eq "MSCIAM"
      ou.referent.metadata["volume"].should eq "56"
      ou.referent.metadata["issue"].should eq "1"
      ou.referent.metadata["spage"].should eq "2"
    end

    it "accepts a Worldcat url" do
      wc_url = "ctx_ver=Z39.88-2004&rfr_id=firstsearch.oclc.org%3AWorldCat&rfr_id=FirstSearch%3AWorldCat&rft_val_fmt=book&url_ver=Z39.88-2004&rft.genre=book&rft.btitle=Principles%20of%20Nano-Optics&rft.title=Principles%20of%20Nano-Optics&rft.au=Novotny%2C%20Lukas&rft.aulast=Novotny&rft.aufirst=Lukas&rft.auinit=L&rft.date=2012&rft.pub=Cambridge%20University%20Press&rft.place=Cambridge&rft.isbn=1-107-00546-9&rft.isbn_13=1-107-00546-9&rft.eisbn=1-139-55054-3&rft_id=oclcnum%3A775664216&rft_id=urn%3AISBN%3A9781107005464&rft_id=doi%3A&rft_dat=775664216%3Cfssessid%3E0%3C%2Ffssessid%3E%3Cedition%3E2nd%20ed.%3C%2Fedition%3E"
      ou = helper.to_open_url(Rack::Utils.parse_query(wc_url))
      ou.referent.format.should eq "book"
      ou.referent.metadata["genre"].should eq "book"
      ou.referrer.identifiers.first.should eq "firstsearch.oclc.org:WorldCat"
      ou.referent.metadata["btitle"].should eq "Principles of Nano-Optics"
      ou.referent.metadata["au"].should eq "Novotny, Lukas"
      ou.referent.metadata["aulast"].should eq "Novotny"
      ou.referent.metadata["aufirst"].should eq "Lukas"
      ou.referent.metadata["auinit"].should eq "L"
      ou.referent.metadata["date"].should eq "2012"
      ou.referent.metadata["pub"].should eq "Cambridge University Press"
      ou.referent.metadata["place"].should eq "Cambridge"
      ou.referent.metadata["isbn"].should eq "1-107-00546-9"
      ou.referent.metadata["eisbn"].should eq "1-139-55054-3"
      ou.referent.identifiers.should include "urn:ISBN:9781107005464"
      ou.referent.identifiers.should include "info:oclcnum/775664216"
    end

    it "accepts a Reaxys url" do
      rx_url = "SID=Elsevier%3AReaxys&aulast=Brorsson&coden=&date=2009&doi=&issn=1465-7740&issue=SUPPL.+1&spage=60&title=Diabetes%2C+O"
      ou = helper.to_open_url(Rack::Utils.parse_query(rx_url))
      ou.should_not be_nil
      ou.referent.metadata["aulast"].should eq "Brorsson"
      ou.referent.metadata["issn"].should eq "1465-7740"
    end

  end

  describe "#solr_params_to_blacklight_query" do

    before do
      @config = Blacklight::Configuration.new do |config|
        config.add_facet_field 'facet'
      end

      helper.stub(:blacklight_config => @config)
    end

    it "leaves a plain query unchanged" do
      helper.solr_params_to_blacklight_query({:unescaped_q => "foo:bar"}).should include(:q => 'foo:bar')
    end

    it "extracts facet queries from the query" do
      params = helper.solr_params_to_blacklight_query({:unescaped_q => "facet:abc foo:bar"})
      params[:q].should eq "foo:bar"
      params[:f].should include("facet" => ["abc"])
    end

    it "convert filter queries to facets" do
      params = helper.solr_params_to_blacklight_query({:fq => ["facet:123", "dont_use:456"]})
      params[:f].should include("facet" => ["123"])
      params[:f].should_not include("dont_use" => ["456"])
    end
  end

  def get_author(name)
    a = OpenURL::Author.new
    a.au = name
    a
  end
end
