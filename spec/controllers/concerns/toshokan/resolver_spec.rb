require "rails_helper"

describe Toshokan::Resolver do

  controller(ApplicationController) { include Toshokan::Resolver }

  describe "#to_open_url" do

    it "returns nil if it can't identify an open url from params" do
      expect( controller.to_open_url({"foo" => "bar"}) ).to be nil
    end

    it "accepts a chemical abstracts url" do
      chem_abs_url = "sid=CAS:CAPLUS&issn=0365-9496&volume=14&coden=BDCGAS&genre=article&spage=1643&title=Berichte der Deutschen Chemischen Gesellschaft&stitle=Ber.&atitle=Barbituric acid&aulast=Guthzeit&aufirst=M&pid=<authfull>Guthzeit, M.</authfull><source>Berichte der Deutschen Chemischen Gesellschaft 14, 1643-5. From: J. Chem. Soc., Abstr. 40, 1033 1881. CODEN:BDCGAS ISSN:0365-9496.</source>"
      ou = controller.to_open_url(Rack::Utils.parse_query(chem_abs_url))
      expect( ou.referent.format ).to eq "journal"
      expect( ou.referent.metadata["genre"] ).to eq "article"
      expect( ou.referent.metadata['issn'] ).to eq "0365-9496"
      expect( ou.referent.metadata['volume'] ).to eq "14"
      expect( ou.referent.metadata['spage'] ).to eq "1643"
      expect( ou.referent.metadata['atitle'] ).to eq "Barbituric acid"
      expect( ou.referent.metadata['jtitle'] ).to eq "Berichte der Deutschen Chemischen Gesellschaft"
      expect( ou.referent.metadata['stitle'] ).to eq "Ber."
      expect( ou.referent.metadata['title'] ).to eq nil
      expect( ou.referent.metadata['aulast'] ).to eq "Guthzeit"
      expect( ou.referent.metadata['aufirst'] ).to eq "M"
    end

    it "accepts an isi url " do
      isi_url = "url_ver=Z39.88-2004&url_ctx_fmt=info:ofi/fmt:kev:mtx:ctx&rft_val_fmt=info:ofi/fmt:kev:mtx:book&rft.artnum=UNSP%20858802&rft.atitle=Promising%20new%20wavelengths%20for%20multi-photon%20fluorescence%20microscopy%3A%20thinking%20outside%20the%20Ti%3ASapphire%20box&rft.aufirst=Greg&rft.aulast=Norris&rft.btitle=MULTIPHOTON%20MICROSCOPY%20IN%20THE%20BIOMEDICAL%20SCIENCES%20XIII&rft.date=2013&rft.genre=proceeding&rft.isbn=978-0-8194-9357-6&rft.issn=0277-786X&rft.place=BELLINGHAM&rft.pub=SPIE-INT%20SOC%20OPTICAL%20ENGINEERING&rft.series=Proceedings%20of%20SPIE&rft.tpages=12&rft.volume=8588&rfr_id=info:sid/www.isinet.com:WoK:WOS&rft.au=Amor%2C%20Rumelo&rft.au=Dempster%2C%20John&rft.au=Amos%2C%20William%20B%2E&rft.au=McConnell%2C%20Gail&rft_id=info:doi/10%2E1117%2F12%2E2008189"
      ou = controller.to_open_url(Rack::Utils.parse_query(isi_url))
      expect( ou.referent.format ).to eq "book"
      expect( ou.referent.metadata["genre"] ).to eq "proceeding"
      expect( ou.referrer.identifiers ).to include "info:sid/www.isinet.com:WoK:WOS"
      expect( ou.referent.metadata['btitle'] ).to eq "MULTIPHOTON MICROSCOPY IN THE BIOMEDICAL SCIENCES XIII"
      expect( ou.referent.metadata['atitle'] ).to eq "Promising new wavelengths for multi-photon fluorescence microscopy: thinking outside the Ti:Sapphire box"
      expect( ou.referent.metadata['aulast'] ).to eq "Norris"
      expect( ou.referent.metadata['aufirst'] ).to eq "Greg"
      expect( ou.referent.metadata['date'] ).to eq "2013"
      expect( ou.referent.metadata['isbn'] ).to eq "978-0-8194-9357-6"
      expect( ou.referent.metadata['issn'] ).to eq "0277-786X"
      expect( ou.referent.metadata['volume'] ).to eq "8588"
      expect( ou.referent.metadata['place'] ).to eq "BELLINGHAM"
      expect( ou.referent.metadata['pub'] ).to eq "SPIE-INT SOC OPTICAL ENGINEERING"
      expect( ou.referent.metadata['series'] ).to eq "Proceedings of SPIE"
      expect( ou.referent.metadata['tpages'] ).to eq "12" # not part of standard, but we'll keep it
      expect( ou.referent.metadata['au'] ).to eq "Amor, Rumelo"
      expect( ou.referent.authors.length ).to eq 5
      expect( ou.referent.identifiers ).to include "info:doi/10.1117/12.2008189"
    end

    it "accepts a short PubMed url" do
      pubmed_url = "sid=Entrez:PubMed&id=pmid:12217522"
      ou = controller.to_open_url(Rack::Utils.parse_query(pubmed_url))
      expect( ou.referrer.identifiers).to include "info:sid/Entrez:PubMed"
      expect( ou.referent.identifiers.first).to eq "info:pmid/12217522"
    end

    it "accepts a Google Scholar url" do
      scholar_url = "sid=google&auinit=K&aulast=Li&atitle=Performance+analysis+of+power-aware+task+scheduling+algorithms+on+multiprocessor+computers+with+dynamic+voltage+and+speed&id=doi:10.1109/TPDS.2008.122&title=IEEE+Transactions+on+Parallel+and+Distributed+Systems&volume=19&issue=11&date=2008&spage=1484&issn=1045-9219"
      ou = controller.to_open_url(Rack::Utils.parse_query(scholar_url))
      expect( ou.referrer.identifiers.first).to eq "info:sid/google"
      expect( ou.referent.metadata["jtitle"]).to eq "IEEE Transactions on Parallel and Distributed Systems"
      expect( ou.referent.metadata["atitle"]).to eq "Performance analysis of power-aware task scheduling algorithms on multiprocessor computers with dynamic voltage and speed"
      expect( ou.referent.metadata["title"]).to be nil
      expect( ou.referent.metadata["auinit"]).to eq "K"
      expect( ou.referent.metadata["aulast"]).to eq "Li"
      expect( ou.referent.authors.length).to be 1
      expect( ou.referent.metadata["volume"]).to eq "19"
      expect( ou.referent.metadata["issue"]).to eq "11"
      expect( ou.referent.metadata["date"]).to eq "2008"
      expect( ou.referent.metadata["spage"]).to eq "1484"
      expect( ou.referent.metadata["issn"]).to eq "1045-9219"
      expect( ou.referent.identifiers.first).to eq "info:doi/10.1109/TPDS.2008.122"
    end

    it "accepts a Google Scholar book url" do
      scholar_url = "sid=google&auinit=NJ&aulast=Gimsing&title=Analysis+of+Erection+Procedures+for+Bridges+with+Combined+Cable+Systems:+Cable+Net+Bridge+Concept&genre=book&date=1980"
      ou = controller.to_open_url(Rack::Utils.parse_query(scholar_url))
      expect( ou.referrer.identifiers.first ).to eq "info:sid/google"
      expect( ou.referent.format ).to eq "book"
      expect( ou.referent.metadata["genre"] ).to eq "book"
      expect( ou.referent.metadata["date"] ).to eq "1980"
      expect( ou.referent.metadata["btitle"] ).to eq "Analysis of Erection Procedures for Bridges with Combined Cable Systems: Cable Net Bridge Concept"
      expect( ou.referent.metadata["auinit"] ).to eq "NJ"
      expect( ou.referent.metadata["aulast"] ).to eq "Gimsing"
    end

    it "accepts a Scopus url" do
      scopus_url = "sid=Elsevier:Scopus&_service_type=getFullTxt&issn=09594388&isbn=&volume=23&issue=1&spage=43&epage=51&pages=43-51&artnum=&date=2013&id=doi:10.1016%252fj.conb.2012.11.006&title=Current+Opinion+in+Neurobiology&atitle=Decoding+the+genetics+of+speech+and+language&aufirst=S.A.&auinit=S.A.&auinit1=S&aulast=Graham"
      ou = controller.to_open_url(Rack::Utils.parse_query(scopus_url))
      expect( ou.referrer.identifiers.first ).to eq "info:sid/Elsevier:Scopus"
      expect( ou.referent.metadata["genre"] ).to eq "article"
      expect( ou.referent.metadata["date"] ).to eq "2013"
      expect( ou.referent.metadata["issn"] ).to eq "09594388"
      expect( ou.referent.metadata ).to_not include ("isbn")
      expect( ou.referent.metadata["volume"] ).to eq "23"
      expect( ou.referent.metadata["issue"] ).to eq "1"
      expect( ou.referent.metadata["spage"] ).to eq "43"
      expect( ou.referent.metadata["epage"] ).to eq "51"
      expect( ou.referent.metadata["pages"] ).to eq "43-51"
      expect( ou.referent.metadata["date"] ).to eq "2013"
      expect( ou.referent.identifiers.first ).to include "info:doi/10.1016%2fj.conb.2012.11.006" # double encoding is handled elsewhere
      expect( ou.referent.metadata["jtitle"] ).to eq "Current Opinion in Neurobiology"
      expect( ou.referent.metadata["atitle"] ).to eq "Decoding the genetics of speech and language"
      expect( ou.referent.metadata["aufirst"] ).to eq "S.A."
      expect( ou.referent.metadata["auinit"] ).to eq "S.A."
      expect( ou.referent.metadata["auinit1"] ).to eq "S"
      expect( ou.referent.metadata["aulast"] ).to eq "Graham"
      expect( ou.referent.authors.length ).to be 1
    end

    it "accepts a Proquest url" do
      proquest_url = "url_ver=Z39.88-2004&rft_val_fmt=info:ofi/fmt:kev:mtx:book&genre=report&sid=ProQ:Aquatic+Science+%2526+Fisheries+Abstracts+%2528ASFA%2529+1%253A+Biological+Sciences+%2526+Living+Resources&atitle=&title=Experiments+in+freezing+of+shrimps.+The+effects+of+vacuum-packing+and+storage+with+use+of+carbon+dioxide+gas.&issn=0078186X&date=1961-01-01&volume=&issue=&spage=10&au=Karsti%252C+O%253BHakvaag%252C+D&isbn=&jtitle=&btitle=Experiments+in+freezing+of+shrimps.+The+effects+of+vacuum-packing+and+storage+with+use+of+carbon+dioxide+gas.&rft_id=info:eric/"
      ou = controller.to_open_url(Rack::Utils.parse_query(proquest_url))
      expect( ou.referent.format ).to eq "book"
      expect( ou.referent.metadata["genre"] ).to eq "report"
      expect( ou.referrer.identifiers.first ).to eq "info:sid/ProQ:Aquatic Science %26 Fisheries Abstracts %28ASFA%29 1%3A Biological Sciences %26 Living Resources" # double encoding is handled elsewhere
      expect( ou.referent.metadata["date"] ).to eq "1961"
      expect( ou.referent.metadata["btitle"] ).to eq "Experiments in freezing of shrimps. The effects of vacuum-packing and storage with use of carbon dioxide gas."
      expect( ou.referent.metadata["issn"] ).to eq "0078186X"
      expect( ou.referent.metadata["spage"] ).to eq "10"
      expect( ou.referent.metadata["au"] ).to eq "Karsti%2C O%3BHakvaag%2C D"
      expect( ou.referent.metadata.length ).to be 7
    end

    it "accepts another Proquest url" do
      proquest_url = "url_ver=Z39.88-2004&rft_val_fmt=info:ofi/fmt:kev:mtx:journal&genre=article&sid=ProQ:ProQ%253Aasfabiological&atitle=Sympatric+occurrence+of+living+Nautilus+%2528N.+pompilius+and+N.+stenomphalaus+%2529+on+the+Great+Barrier+Reef%252C+Australia.&title=Nautilus&issn=00281344&date=1988-01-01&volume=102&issue=1&spage=188&au=Saunders%252C+W+B%253BWard%252C+P+D&isbn=&jtitle=Nautilus&btitle=&rft_id=info:eric/"
      ou = controller.to_open_url(Rack::Utils.parse_query(proquest_url))
      expect( ou.referent.format ).to eq "journal"
      expect( ou.referent.metadata["genre"] ).to eq "article"
      expect( ou.referent.metadata["atitle"] ).to eq "Sympatric occurrence of living Nautilus %28N. pompilius and N. stenomphalaus %29 on the Great Barrier Reef%2C Australia." # double encoding is handled elsewhere
      expect( ou.referent.metadata["jtitle"] ).to eq "Nautilus"
      expect( ou.referent.metadata["date"] ).to eq "1988"
      expect( ou.referent.metadata["issn"] ).to eq "00281344"
      expect( ou.referent.metadata["volume"] ).to eq "102"
      expect( ou.referent.metadata["issue"] ).to eq "1"
      expect( ou.referent.metadata["spage"] ).to eq "188"
      expect( ou.referent.metadata["au"] ).to eq "Saunders%2C W B%3BWard%2C P D"
    end

    it "accepts a Primo url" do
      primo_url = "ctx_enc=UTF-8&ctx_ver=Z39.88-2004&rfr_id=primo.exlibrisgroup.com%3Aprimo3-Article-gale_ofa&svc_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Asch_svc&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&url_ver=Z39.88-2004&rft.genre=article&rft.atitle=Management%20science%202009%20Report.%28Letter%20from%20the%20Editor%29%28Report%29&rft.jtitle=Management%20science&rft.stitle=MANAGE%20SCI&rft.stitle=MANAG%20SCI&rft.title=Management%20science&rft.au=Cachon%2C%20Gerard%20P&rft.aulast=Cachon&rft.aufirst=Gerard&rft.auinit=G%20P&rft.date=20100101&rft.pub=INFORMS&rft.place=%5BLinthicum%2C%20Md.%5D&rft.issn=0025-1909&rft.eissn=1526-5501&rft.coden=MSCIAM&rft.volume=56&rft.issue=1&rft.spage=2&rft_id=doi%3A&rft_id=oai%3A%3E&rft_dat=%3Cgale_ofa%3E219382786%3C%2Fgale_ofa%3E%3Cgrp_id%3E7617128399622374774%3C%2Fgrp_id%3E%3Coa%3E%3C%2Foa%3E&req.language=eng"
      ou = controller.to_open_url(Rack::Utils.parse_query(primo_url))
      expect( ou.referent.format ).to eq "journal"
      expect( ou.referent.metadata["genre"] ).to eq "article"
      expect( ou.referent.metadata["atitle"] ).to eq "Management science 2009 Report.(Letter from the Editor)(Report)"
      expect( ou.referent.metadata["jtitle"] ).to eq "Management science"
      expect( ou.referent.metadata["stitle"] ).to eq "MANAGE SCI"
      expect( ou.referent.metadata["title"] ).to be nil
      expect( ou.referent.metadata["au"] ).to eq "Cachon, Gerard P"
      expect( ou.referent.metadata["aulast"] ).to eq "Cachon"
      expect( ou.referent.metadata["aufirst"] ).to eq "Gerard"
      expect( ou.referent.metadata["auinit"] ).to eq "G P"
      expect( ou.referent.metadata["date"] ).to eq "2010"
      expect( ou.referent.metadata["pub"] ).to eq "INFORMS"
      expect( ou.referent.metadata["place"] ).to eq "[Linthicum, Md.]"
      expect( ou.referent.metadata["issn"] ).to eq "0025-1909"
      expect( ou.referent.metadata["eissn"] ).to eq "1526-5501"
      expect( ou.referent.metadata["coden"] ).to eq "MSCIAM"
      expect( ou.referent.metadata["volume"] ).to eq "56"
      expect( ou.referent.metadata["issue"] ).to eq "1"
      expect( ou.referent.metadata["spage"] ).to eq "2"
    end

    it "accepts a Worldcat url" do
      wc_url = "ctx_ver=Z39.88-2004&rfr_id=firstsearch.oclc.org%3AWorldCat&rfr_id=FirstSearch%3AWorldCat&rft_val_fmt=book&url_ver=Z39.88-2004&rft.genre=book&rft.btitle=Principles%20of%20Nano-Optics&rft.title=Principles%20of%20Nano-Optics&rft.au=Novotny%2C%20Lukas&rft.aulast=Novotny&rft.aufirst=Lukas&rft.auinit=L&rft.date=2012&rft.pub=Cambridge%20University%20Press&rft.place=Cambridge&rft.isbn=1-107-00546-9&rft.isbn_13=1-107-00546-9&rft.eisbn=1-139-55054-3&rft_id=oclcnum%3A775664216&rft_id=urn%3AISBN%3A9781107005464&rft_id=doi%3A&rft_dat=775664216%3Cfssessid%3E0%3C%2Ffssessid%3E%3Cedition%3E2nd%20ed.%3C%2Fedition%3E"
      ou = controller.to_open_url(Rack::Utils.parse_query(wc_url))
      expect( ou.referent.format ).to eq "book"
      expect( ou.referent.metadata["genre"] ).to eq "book"
      expect( ou.referrer.identifiers.first ).to eq "firstsearch.oclc.org:WorldCat"
      expect( ou.referent.metadata["btitle"] ).to eq "Principles of Nano-Optics"
      expect( ou.referent.metadata["au"] ).to eq "Novotny, Lukas"
      expect( ou.referent.metadata["aulast"] ).to eq "Novotny"
      expect( ou.referent.metadata["aufirst"] ).to eq "Lukas"
      expect( ou.referent.metadata["auinit"] ).to eq "L"
      expect( ou.referent.metadata["date"] ).to eq "2012"
      expect( ou.referent.metadata["pub"] ).to eq "Cambridge University Press"
      expect( ou.referent.metadata["place"] ).to eq "Cambridge"
      expect( ou.referent.metadata["isbn"] ).to eq "1-107-00546-9"
      expect( ou.referent.metadata["eisbn"] ).to eq "1-139-55054-3"
      expect( ou.referent.identifiers ).to include "urn:ISBN:9781107005464"
      expect( ou.referent.identifiers ).to include "info:oclcnum/775664216"
    end

    it "accepts a Reaxys url" do
      rx_url = "SID=Elsevier%3AReaxys&aulast=Brorsson&coden=&date=2009&doi=&issn=1465-7740&issue=SUPPL.+1&spage=60&title=Diabetes%2C+O"
      ou = controller.to_open_url(Rack::Utils.parse_query(rx_url))
      expect(ou).to_not be_nil
      expect( ou.referent.metadata["aulast"] ).to eq "Brorsson"
      expect( ou.referent.metadata["issn"] ).to eq "1465-7740"
    end

  end

  describe "#solr_params_to_blacklight_query" do

    let(:blacklight_config) do
      Blacklight::Configuration.new do |config|
        config.add_facet_field 'facet'
      end
    end

    before do
      controller.extend Blacklight::Controller # the blacklight_config method must be defined on the class in order to stub it
      allow(controller).to receive(:blacklight_config).and_return(blacklight_config)
    end

    it "leaves a plain query unchanged" do
      expect( controller.solr_params_to_blacklight_query({:unescaped_q => "foo:bar"}) ).to include(:q => 'foo:bar')
    end

    it "extracts facet queries from the query" do
      params = controller.solr_params_to_blacklight_query({:unescaped_q => "facet:abc foo:bar"})
      expect( params[:q] ).to eq "foo:bar"
      expect( params[:f] ).to include("facet" => ["abc"])
    end

    it "convert filter queries to facets" do
      params = controller.solr_params_to_blacklight_query({:fq => ["facet:123", "dont_use:456"]})
      expect( params[:f] ).to include("facet" => ["123"])
      expect( params[:f] ).to_not include("dont_use" => ["456"])
    end
  end

  def get_author(name)
    a = OpenURL::Author.new
    a.au = name
    a
  end
end
