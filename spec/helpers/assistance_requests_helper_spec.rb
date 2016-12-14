require 'rails_helper'
describe AssistanceRequestsHelper do
  describe 'assistance_request_link' do
    subject { helper.assistance_request_link(document) }
    context 'when it is a synthetic document' do
      let(:document){ SolrDocument.new(title_ts:'ELECTROCHEMICAL SCIENCE AND TECHNOLOGY OF COPPER, PROCEEDINGS', format: 'book')}
      it { should include 'genre=book' }
      it { should include CGI.escape('assistance_request[book_title]')}
      it { should include CGI.escape('ELECTROCHEMICAL SCIENCE AND TECHNOLOGY') }
    end
    context 'when it is a document in the index' do
      let(:document) { SolrDocument.new(cluster_id_ss: ['5983']) }
      it { should include 'record_id=5983' }
    end
  end
end
