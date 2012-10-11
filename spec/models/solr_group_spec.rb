require 'spec_helper'

def get_doc
	{"groupValue"=>"227651392", 
    	"doclist"=>{"numFound"=>2, "start"=>0, "maxScore"=>2.0106137, 
        	"docs"=>[
            	{"id"=>"12345", "cluster_id"=>"227651392", "format"=>"article", "fulltext"=>"R", "bfi_level"=>"", "source_type"=>"openaccess", "source"=>"arxiv", "alert_timestamp"=>"2012-09-28T11:15:15.066Z", "title_t"=>["5D SYM on 3D Sphere and 2D YM"], "abstract_t"=>["It is shown by using localization that in five-dimensional N=1 supersymmetric\n                                Yang-Mills theory on a three-dimensional sphere, correlation functions in a sector are\n                                identical to correlation functions in two-dimensional bosonic Yang-Mills theory.\n                            ", "Comment: 8 pages, LaTeX; a minor clarification and typos corrected"], "author_name_t"=>["Kawano, Teruhiko", "Matsumiya, Nariaki"], "author_name_facet"=>["Kawano, Teruhiko", "Matsumiya, Nariaki"], "pub_date"=>2012, "pub_date_sort"=>2012, "keywords_t"=>["High Energy Physics - Theory"], "keywords_facet"=>["High Energy Physics - Theory"], "access"=>["dtu"], "timestamp"=>"2012-09-28T11:18:37.339Z", "score"=>2.0106137},
            	{"id"=>"67890", "cluster_id"=>"227651392", "format"=>"article", "fulltext"=>"R", "bfi_level"=>"", "source_type"=>"aggregator", "source"=>"some_source", "source_url"=>"www.example.com", "alert_timestamp"=>"2012-09-28T11:15:15.066Z", "title_t"=>["5D SYM on 3D Sphere and 2D YM"], "abstract_t"=>["It is shown by using localization that in five-dimensional N=1 supersymmetric\n                                Yang-Mills theory on a three-dimensional sphere, correlation functions in a sector are\n                                identical to correlation functions in two-dimensional bosonic Yang-Mills theory.\n                            ", "Comment: 8 pages, LaTeX; a minor clarification and typos corrected"], "author_name_t"=>["Kawano, Teruhiko", "Matsumiya, Nariaki"], "author_name_facet"=>["Kawano, Teruhiko", "Matsumiya, Nariaki"], "pub_date"=>2012, "pub_date_sort"=>2012, "keywords_t"=>["High Energy Physics - Theory"], "keywords_facet"=>["High Energy Physics - Theory"], "access"=>["dtu"], "timestamp"=>"2012-09-28T11:18:37.339Z", "score"=>2.0106137}
        	]
    	}
	} 
end

describe SolrGroup do

  before(:each) do
    @solrdoc = SolrGroup.new(get_doc, nil) 
  end

  describe "access methods" do

    it "returns the right id" do
      @solrdoc.id.should == '227651392'
  	end 

    it "returns the right member id" do
      @solrdoc.member_id.should == '12345'		
    end	

    it "returns the right format" do
      @solrdoc['format'].should == 'article'
    end	

    it "returns the source url for a source" do
      @solrdoc.source_url("some_source").should == 'www.example.com'
      @solrdoc.source_url("arxiv").should == ""
    end  

  end
end
