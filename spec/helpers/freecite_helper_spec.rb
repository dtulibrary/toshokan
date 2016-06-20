require 'rails_helper'

describe "FreeciteHelper::FreeciteRequest" do
  describe "#call" do
    it "returns a response with journal title, volume and page" do
      stub_request(:post, "http://freecite.library.brown.edu/citations/create").
        to_return(
:status => 200,
:body => "<citations>
<citation valid='false'><authors><author>A K Huber</author><author>M Falk</author><author>M Rohnke</author><author>B Luerssen</author><author>L Gregoratti</author><author>M Amati</author><author>J Janek</author></authors><journal>Physical Chemistry Chemical Physics 2012</journal><volume>14</volume><pages>751</pages><raw_string>Huber, A. K.; Falk, M.; Rohnke, M.; Luerssen, B.; Gregoratti, L.; Amati, M.; Janek, J. Physical Chemistry Chemical Physics 2012, 14, 751</raw_string></citation>
<ctx:context-objects xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation='info:ofi/fmt:xml:xsd:ctx http://www.openurl.info/registry/docs/info:ofi/fmt:xml:xsd:ctx' xmlns:ctx='info:ofi/fmt:xml:xsd:ctx'><ctx:context-object timestamp='2016-06-02T04:54:15-04:00' encoding='info:ofi/enc:UTF-8' version='Z39.88-2004' identifier=''><ctx:referent><ctx:metadata-by-val><ctx:format>info:ofi/fmt:xml:xsd:journal</ctx:format><ctx:metadata><journal xmlns:rft='info:ofi/fmt:xml:xsd:journal' xsi:schemaLocation='info:ofi/fmt:xml:xsd:journal http://www.openurl.info/registry/docs/info:ofi/fmt:xml:xsd:journal'><rft:date></rft:date><rft:stitle>Physical Chemistry Chemical Physics 2012</rft:stitle><rft:genre>article</rft:genre><rft:pages>751</rft:pages><rft:volume>14</rft:volume><rft:au>A K Huber</rft:au><rft:au>M Falk</rft:au><rft:au>M Rohnke</rft:au><rft:au>B Luerssen</rft:au><rft:au>L Gregoratti</rft:au><rft:au>M Amati</rft:au><rft:au>J Janek</rft:au></journal></ctx:metadata></ctx:metadata-by-val></ctx:referent></ctx:context-object></ctx:context-objects></citations>",
 :headers => {})

      response = FreeciteHelper::FreeciteRequest.new("Huber, A. K.; Falk, M.; Rohnke, M.; Luerssen, B.; Gregoratti, L.; Amati, M.; Janek, J. Physical Chemistry Chemical Physics 2012, 14, 751").call

      expect(response.journal_title).to eq("Physical Chemistry Chemical Physics 2012")
      expect(response.volume).to eq("14")
      expect(response.page).to eq("751")
    end

    it "returns a response with the unabbreviated names of the first author" do
      stub_request(:post, "http://freecite.library.brown.edu/citations/create").
        to_return(
:status => 200,
:body => "<citations>
<citation valid='false'><authors><author>A K Huber</author><author>M Falk</author><author>M Rohnke</author><author>B Luerssen</author><author>L Gregoratti</author><author>M Amati</author><author>J Janek</author></authors><journal>Physical Chemistry Chemical Physics 2012</journal><volume>14</volume><pages>751</pages><raw_string>Huber, A. K.; Falk, M.; Rohnke, M.; Luerssen, B.; Gregoratti, L.; Amati, M.; Janek, J. Physical Chemistry Chemical Physics 2012, 14, 751</raw_string></citation>
<ctx:context-objects xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation='info:ofi/fmt:xml:xsd:ctx http://www.openurl.info/registry/docs/info:ofi/fmt:xml:xsd:ctx' xmlns:ctx='info:ofi/fmt:xml:xsd:ctx'><ctx:context-object timestamp='2016-06-02T04:54:15-04:00' encoding='info:ofi/enc:UTF-8' version='Z39.88-2004' identifier=''><ctx:referent><ctx:metadata-by-val><ctx:format>info:ofi/fmt:xml:xsd:journal</ctx:format><ctx:metadata><journal xmlns:rft='info:ofi/fmt:xml:xsd:journal' xsi:schemaLocation='info:ofi/fmt:xml:xsd:journal http://www.openurl.info/registry/docs/info:ofi/fmt:xml:xsd:journal'><rft:date></rft:date><rft:stitle>Physical Chemistry Chemical Physics 2012</rft:stitle><rft:genre>article</rft:genre><rft:pages>751</rft:pages><rft:volume>14</rft:volume><rft:au>A K Huber</rft:au><rft:au>M Falk</rft:au><rft:au>M Rohnke</rft:au><rft:au>B Luerssen</rft:au><rft:au>L Gregoratti</rft:au><rft:au>M Amati</rft:au><rft:au>J Janek</rft:au></journal></ctx:metadata></ctx:metadata-by-val></ctx:referent></ctx:context-object></ctx:context-objects></citations>",
 :headers => {})

      response = FreeciteHelper::FreeciteRequest.new("Huber, A. K.; Falk, M.; Rohnke, M.; Luerssen, B.; Gregoratti, L.; Amati, M.; Janek, J. Physical Chemistry Chemical Physics 2012, 14, 751").call

      expect(response.unabbreviated_names_of_the_first_author).to eq("Huber")
    end
  end
end
