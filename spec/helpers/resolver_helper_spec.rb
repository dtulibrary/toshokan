require "spec_helper"

describe ResolverHelper do

  describe "#to_open_url" do

    it "returns nil if it can't identify an open url from params" do
      helper.to_open_url({"foo" => "bar"}).should be nil
    end

    it "accepts a chemical abstracts url" do
      chem_abs_url = "sid=CAS:CAPLUS&issn=0365-9496&volume=14&coden=BDCGAS&genre=article&spage=1643&title=Berichte der Deutschen Chemischen Gesellschaft&stitle=Ber.&atitle=Barbituric acid&aulast=Guthzeit&aufirst=M&pid=<authfull>Guthzeit, M.</authfull><source>Berichte der Deutschen Chemischen Gesellschaft 14, 1643-5. From: J. Chem. Soc., Abstr. 40, 1033 1881. CODEN:BDCGAS ISSN:0365-9496.</source>"
      ou = helper.to_open_url(Rack::Utils.parse_query(chem_abs_url))
      ou.referent.metadata['jtitle'].should eq "Berichte der Deutschen Chemischen Gesellschaft"
    end

    it "accepts an isi url " do
      isi_url = "url_ver=Z39.88-2004&url_ctx_fmt=info:ofi/fmt:kev:mtx:ctx&rft_val_fmt=info:ofi/fmt:kev:mtx:book&rft.artnum=UNSP%20858802&rft.atitle=Promising%20new%20wavelengths%20for%20multi-photon%20fluorescence%20microscopy%3A%20thinking%20outside%20the%20Ti%3ASapphire%20box&rft.aufirst=Greg&rft.aulast=Norris&rft.btitle=MULTIPHOTON%20MICROSCOPY%20IN%20THE%20BIOMEDICAL%20SCIENCES%20XIII&rft.date=2013&rft.genre=proceeding&rft.isbn=978-0-8194-9357-6&rft.issn=0277-786X&rft.place=BELLINGHAM&rft.pub=SPIE-INT%20SOC%20OPTICAL%20ENGINEERING&rft.series=Proceedings%20of%20SPIE&rft.tpages=12&rft.volume=8588&rfr_id=info:sid/www.isinet.com:WoK:WOS&rft.au=Amor%2C%20Rumelo&rft.au=Dempster%2C%20John&rft.au=Amos%2C%20William%20B%2E&rft.au=McConnell%2C%20Gail&rft_id=info:doi/10%2E1117%2F12%2E2008189"
      ou = helper.to_open_url(Rack::Utils.parse_query(isi_url))
      ou.referrer.identifiers.first.should eq "info:sid/www.isinet.com:WoK:WOS"
    end

    it "accepts a short PubMed url" do
      pubmed_url = "sid=Entrez:PubMed&id=pmid:12217522"
      ou = helper.to_open_url(Rack::Utils.parse_query(pubmed_url))
      ou.referent.identifiers.first.should eq "info:pmid/12217522"
    end

    it "accepts a Google Scholar url" do
      scholar_url = "sid=google&auinit=K&aulast=Li&atitle=Performance+analysis+of+power-aware+task+scheduling+algorithms+on+multiprocessor+computers+with+dynamic+voltage+and+speed&id=doi:10.1109/TPDS.2008.122&title=IEEE+Transactions+on+Parallel+and+Distributed+Systems&volume=19&issue=11&date=2008&spage=1484&issn=1045-9219"
      ou = helper.to_open_url(Rack::Utils.parse_query(scholar_url))
      ou.referrer.identifiers.first.should eq "info:sid/google"
      ou.referent.metadata["jtitle"].should eq "IEEE Transactions on Parallel and Distributed Systems"
      ou.referent.metadata["title"].should be nil
    end

    it "accepts a Scopus url" do
      scopus_url = "sid=Elsevier:Scopus&_service_type=getFullTxt&issn=09594388&isbn=&volume=23&issue=1&spage=43&epage=51&pages=43-51&artnum=&date=2013&id=doi:10.1016%252fj.conb.2012.11.006&title=Current+Opinion+in+Neurobiology&atitle=Decoding+the+genetics+of+speech+and+language&aufirst=S.A.&auinit=S.A.&auinit1=S&aulast=Graham"
      ou = helper.to_open_url(Rack::Utils.parse_query(scopus_url))
      ou.referent.metadata["genre"].should eq "article"
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
      helper.solr_params_to_blacklight_query({:q => "foo:bar"}).should include(:q => 'foo:bar')
    end

    it "extracts facet queries from the query" do
      params = helper.solr_params_to_blacklight_query({:q => "facet:abc foo:bar"})
      params[:q].should eq "foo:bar"
      params[:f].should include("facet" => ["abc"])
    end

    it "convert filter queries to facets" do
      params = helper.solr_params_to_blacklight_query({:fq => ["facet:123", "dont_use:456"]})
      params[:f].should include("facet" => ["123"])
      params[:f].should_not include("dont_use" => ["456"])
    end
  end
end