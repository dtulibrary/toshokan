require 'rails_helper'

describe "FreeciteHelper::FreeciteRequest" do
  describe "#call" do
    it "returns a response with journal title, volume and pages" do
      stub_request(:get, "http://freecite:3000/citations/search?q=Huber,%20A.%20K.%3B%20Falk,%20M.%3B%20Rohnke,%20M.%3B%20Luerssen,%20B.%3B%20Gregoratti,%20L.%3B%20Amati,%20M.%3B%20Janek,%20J.%20Physical%20Chemistry%20Chemical%20Physics%202012,%2014,%20751").
        to_return(:status => 200,
                  :body => '{"author":"Huber,  A. K.,  Falk,  M.,  Rohnke,  M.,  Luerssen,  B.,  Gregoratti,  L.,  Amati,  M.,  Janek,  J. ","journal":"Physical Chemistry Chemical Physics","date":2012,"volume":"14","pages":"751","authors":["A K Huber","M Falk","M Rohnke","B Luerssen","L Gregoratti","M Amati","J Janek"],"year":2012,"raw_string":"Huber, A. K.; Falk, M.; Rohnke, M.; Luerssen, B.; Gregoratti, L.; Amati, M.; Janek, J. Physical Chemistry Chemical Physics 2012, 14, 751"}',
                  :headers => {})

      response = FreeciteHelper::FreeciteRequest.new("http://freecite:3000/citations/search", "Huber, A. K.; Falk, M.; Rohnke, M.; Luerssen, B.; Gregoratti, L.; Amati, M.; Janek, J. Physical Chemistry Chemical Physics 2012, 14, 751").call

      expect(response.journal_title).to eq("Physical Chemistry Chemical Physics")
      expect(response.volume).to eq("14")
      expect(response.pages).to eq("751")
    end

    it "returns a response with the unabbreviated names of the first author" do
      stub_request(:get, "http://freecite:3000/citations/search?q=Huber,%20A.%20K.%3B%20Falk,%20M.%3B%20Rohnke,%20M.%3B%20Luerssen,%20B.%3B%20Gregoratti,%20L.%3B%20Amati,%20M.%3B%20Janek,%20J.%20Physical%20Chemistry%20Chemical%20Physics%202012,%2014,%20751").
        to_return(:status => 200,
                  :body => '{"author":"Huber,  A. K.,  Falk,  M.,  Rohnke,  M.,  Luerssen,  B.,  Gregoratti,  L.,  Amati,  M.,  Janek,  J. ","journal":"Physical Chemistry Chemical Physics","date":2012,"volume":"14","pages":"751","authors":["A K Huber","M Falk","M Rohnke","B Luerssen","L Gregoratti","M Amati","J Janek"],"year":2012,"raw_string":"Huber, A. K.; Falk, M.; Rohnke, M.; Luerssen, B.; Gregoratti, L.; Amati, M.; Janek, J. Physical Chemistry Chemical Physics 2012, 14, 751"}',
                  :headers => {})

      response = FreeciteHelper::FreeciteRequest.new("http://freecite:3000/citations/search", "Huber, A. K.; Falk, M.; Rohnke, M.; Luerssen, B.; Gregoratti, L.; Amati, M.; Janek, J. Physical Chemistry Chemical Physics 2012, 14, 751").call

      expect(response.unabbreviated_names_of_the_first_author).to eq("Huber")
    end
  end
end
