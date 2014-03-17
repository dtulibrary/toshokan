require 'spec_helper'

describe ResolverController do

  describe '#index' do

    single_doc_open_url=
        "url_ver=Z39.88-2004&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&ctx_ver=Z39.88-2004" +
        "&ctx_enc=info%3Aofi%2Fenc%3AUTF-8&rft.genre=article&rft.atitle=Effect+of+phenolic+compounds+and+osmotic+stress+on+the+expression" +
        "+of+penicillin+biosynthetic+genes+from+Penicillium+chrysogenum+var.+halophenolicum+strain" +
        "&rft.au=Guedes%2C+Sumaya+Ferreira&rft.jtitle=Journal+of+Xenobiotics&rft.volume=2&rft.issue=1&rft.date=2012" +
        "&rft.issn=20394705&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft_id=urn%3Aissn%3A20394705"

    it "redirects to a single document page" do
      open_url = Rack::Utils.parse_nested_query(single_doc_open_url)

      get :index, open_url
      response.should redirect_to(catalog_path(:id => "191288369"))
    end

    it "redirects to a search result" do
      open_url =
        "url_ver=Z39.88-2004&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&ctx_ver=Z39.88-2004&" +
        "ctx_enc=info%3Aofi%2Fenc%3AUTF-8&rft.genre=article&rft.jtitle=Journal+of+Xenobiotics"
      open_url = Rack::Utils.parse_nested_query(open_url)
      query_params = {}
      query_params[:q] = "journaltitle:(Journal of Xenobiotics)"
      query_params[:f] = {"format" => ["article"]}
      query_params[:from_resolver] = true

      get :index, open_url
      response.should redirect_to(catalog_index_path(query_params))
    end

    it "shows a synthesized single document page" do
      open_url =
        "url_ver=Z39.88-2004&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&ctx_ver=Z39.88-2004" +
        "&ctx_enc=info%3Aofi%2Fenc%3AUTF-8&rft.genre=article&rft.atitle=some+fake+title" +
        "&rft.au=Lastname%2C+Firstname&rft.jtitle=Journal+of+Stuff&rft.volume=2&rft.issue=1&rft.date=2012" +
        "&rft.issn=12345678&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft_id=urn%3Aissn%3A12345678"
      open_url = Rack::Utils.parse_nested_query(open_url)

      get :index, open_url
      response.should render_template('catalog/show')
    end

    context "search in Solr is not possible" do

      before do
        fake_error = RSolr::Error::Http.new({}, {})
        controller.stub(:get_resolver_result) { |*args| raise fake_error }
      end

      it "redirects to root" do
        open_url = Rack::Utils.parse_nested_query(single_doc_open_url)

        get :index, open_url
        # using the standard blacklight rescue_from
        # might consider to override this and create a synthesized record instead
        response.should redirect_to(root_url)
      end
    end

    context "redirecting to SFX" do

      it "redirects if it asks for a SFX response type" do
        open_url =
          "sfx.response_type=simplexml&svc.fulltext=yes&ctx_enc=UTF-8&rfr_id=Entrez%3APubMed&rft.genre=article&" +
          "rft.atitle=Limbic-cortical%20dysregulation%3A%20a%20proposed%20model%20of%20depression.&" +
          "rft.jtitle=The%20Journal%20of%20neuropsychiatry%20and%20clinical%20neurosciences&rft.stitle=J%20NEUROPSYCHIATRY%20CLIN%20NEUROSCI&" +
          "rft.au=Mayberg%2C%20H%20S&rft.aulast=Mayberg&rft.aufirst=&rft.auinit=H%20S&rft.pub=American%20Psychiatric%20Press&" +
          "rft.place=Washington%2C%20DC&rft.issn=0895-0172&rft.eissn=1545-7222&rft.coden=JNCNE7&rft.volume=9&rft.issue=3&rft.spage=471&rft.epage=481&rft_id=pmid%3A9276848";
        open_url = Rack::Utils.parse_nested_query(open_url)

        get :index, open_url
        response.should redirect_to("#{Rails.application.config.resolve[:sfx_url]}?#{open_url.to_query}&fromfindit=true")
      end

      it "redirects if the request contains a SFX request id" do
        open_url = "url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&ctx_enc=info:ofi/enc:UTF-8&url_ctx_fmt=infofi/fmt:kev:mtx:ctx&rft.object_id=123456789&sfx.request_id=123456789&sfx.ctx_obj_item=0"
        open_url = Rack::Utils.parse_nested_query(open_url)

        get :index, open_url
        response.should redirect_to("#{Rails.application.config.resolve[:sfx_url]}?#{open_url.to_query}&fromfindit=true")
      end

      it "redirects if its an image based linking request" do
        open_url = "sid=Elsevier:Scopus&__response_type=image-large&__service_type=getFullTxt&issn=0022149X&date=2013"
        open_url = Rack::Utils.parse_nested_query(open_url)

        get :index, open_url
        response.should redirect_to("#{Rails.application.config.resolve[:sfx_url]}?#{open_url.to_query}&fromfindit=true")
      end

      it "redirects if it can't create an OpenURL from the request parameters" do
        open_url = Rack::Utils.parse_nested_query("somerandomthing=randomthing")

        get :index, open_url
        response.should redirect_to("#{Rails.application.config.resolve[:sfx_url]}?#{open_url.to_query}&fromfindit=true")
      end
    end
  end
end
