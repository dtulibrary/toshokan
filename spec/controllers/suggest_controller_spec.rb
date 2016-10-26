require 'rails_helper'

describe SuggestController do
  describe "#index" do
    it "returns a body" do
      solr_response = {'responseHeader'=>{'status'=>0,'QTime'=>2},'suggest'=>{'metastore_dictionary_lookup'=>{'wind'=>{'numFound'=>3,'suggestions'=>[{'term'=>'Winding, A.','weight'=>7,'payload'=>''},{'term'=>'Winding, U.','weight'=>7,'payload'=>''},{'term'=>'Performance computing : The UNIX and Windows NT enterprice magazine','weight'=>1,'payload'=>''}]}}}}
      allow_any_instance_of(RSolr::Client).to receive(:send_and_receive).and_return solr_response
      get :index, q: "wind", format: :json
      puts response.body
      expect(response.body).to be_an Array
    end
  end
end
