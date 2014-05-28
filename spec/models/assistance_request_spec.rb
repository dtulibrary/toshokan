require 'spec_helper'

describe AssistanceRequest do

  describe "#openurl" do

    it "creates an OpenURL from a journal article assistance request" do
      ar = JournalArticleAssistanceRequest.new({:article_title => "test title", :journal_title => "test journal title", :journal_volume => "1", :journal_issue => "2", :journal_year => "2014", :journal_pages => "34" })
      ar.openurl.kev.should include "rft.atitle=test+title&rft.jtitle=test+journal+title&rft.volumne=1&rft.issue=2&rft.date=2014&rft.pages=34&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal"
    end
  end
end