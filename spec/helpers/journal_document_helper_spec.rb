require "rails_helper"

describe JournalDocumentHelper do
  let(:document) { SolrDocument.new("journal_title_ts"=>["New England Journal of Medicine"], "conference_title_ts"=>["Magic, The Gathering"]) }
  let(:document_with_complete_metadata) { SolrDocument.new(issn_ss:["an_issn"], "journal_title_ts"=>["Journal of the American Medical Association"], "conference_title_ts"=>["The Quarter Quell"], "pub_date_tis"=>["2014-11-11"], "journal_vol_ssf"=>["45"], "journal_issue_ssf"=>["6"], "journal_part_ssf"=>["Part1"] ) }


  describe "render_journal_info_show" do
    it "renders journal_info" do
      expect(helper.render_journal_info_show(document:document, field:"journal_title_ts")).to eq("New England Journal of Medicine — ")
    end
    describe "when document has toc" do
      let(:document) { SolrDocument.new(toc_key_s:"2345", issn_ss:["an_issn"], "journal_title_ts"=>["New England Journal of Medicine"])}
      it "includes link to find articles in same issue" do
        rendered = helper.render_journal_info_show(document:document, field:"journal_title_ts")
        expect(rendered).to have_content("New England Journal of Medicine —")
        expect(rendered).to have_xpath("//a[@title='Find all articles in same issue']")
        expect(rendered).to_not have_xpath("//a[@title='Open table of contents']")
      end
      it "displays journal title as link to journal toc if possible" do
        document[:toc_key_journal_exists] = true
        rendered = helper.render_journal_info_show(document:document, field:"journal_title_ts")
        expect(rendered).to have_xpath("//a[@title='Open table of contents' and text()='New England Journal of Medicine']")
        expect(rendered).to have_xpath("//a[@title='Find all articles in same issue']")
      end
    end
  end
  describe "render_journal_info_index" do
    it "renders journal_info" do
      expect(helper.render_journal_info_index(document:document, field:"journal_title_ts")).to eq("New England Journal of Medicine — ")
    end
    describe "when document has toc" do
      let(:document) { SolrDocument.new(toc_key_s:"2345", issn_ss:["an_issn"], "journal_title_ts"=>["New England Journal of Medicine"])}
      it "includes link to find articles in same issue" do
        rendered = helper.render_journal_info_index(document:document, field:"journal_title_ts")
        expect(rendered).to have_content("New England Journal of Medicine —")
        expect(rendered).to have_xpath("//a[@title='Find all articles in same issue']")
        expect(rendered).to_not have_xpath("//a[@title='Open table of contents']")
      end
      it "DOES NOT (for now) display journal title as link to journal toc if possible" do
        document[:toc_key_journal_exists] = true
        rendered = helper.render_journal_info_index(document:document, field:"journal_title_ts")
        expect(rendered).to have_xpath("//a[@title='Find all articles in same issue']")
        # This is disabled until we have journal records for all toc-issns
        # expect(rendered).to have_xpath("//a[@title='Open table of contents' and text()='New England Journal of Medicine']")
        # Instead, it renders:
        expect(rendered).to have_content("New England Journal of Medicine —")
      end
    end
  end

  describe "render_conference_info_index" do
    it "combines conference info with journal info" do
      expect(helper).to receive(:render_journal_info).and_return("JOURNAL INFO")
      expect(helper).to receive(:render_journal_page_info).and_return(" &mdash; JOURNAL PAGE INFO")
      expect(helper.render_conference_info_index(document:document, field:"conference_title_ts")).to eq("Magic, The Gathering &mdash; JOURNAL INFO &mdash; JOURNAL PAGE INFO")
    end
  end

  describe "render_conference_info_show" do
    it "relies on conference_info_index if when journal_title_ts is not set" do
      document = SolrDocument.new()
      expect(helper).to receive(:render_conference_info_index).with(document:document, field:"conference_title_ts")
      helper.render_conference_info_show(document:document, field:"conference_title_ts")
    end
    it "when journal_title_ts is set, returns the value of requested field (presumably conference title field)" do
      expect(helper.render_conference_info_show(document:document, field:"conference_title_ts")).to eq("Magic, The Gathering")
    end
  end

  it "renders journal_metadata" do
    expect(helper.render_journal_metadata(document_with_complete_metadata, nil)).to eq("2014-11-11, Volume 45, Issue 6, Part1")
  end
  it "render_journal_metadata_from_parts" do
    expect(helper.render_journal_metadata_from_parts("YEAR","VOLUME", "ISSUE", "PART")).to eq("YEAR, Volume VOLUME, Issue ISSUE, PART")
  end
  describe "render_journal_page_info" do
    it "renders journal_page_ssf or nothing" do
      expect( render_journal_page_info(document, nil)).to eq("")
      document["journal_page_ssf"] = "45"
      expect( render_journal_page_info(document, nil)).to eq(", pp. 4")
    end
  end
  describe "render_journal_rank" do
    it "renders link to Scopus journal rank" do
      rendered = render_journal_rank(document_with_complete_metadata)
      expect(rendered).to have_css("li", text:"Journal ranks")
      expect(rendered).to have_link("Scopus journal rank",href: Rails.application.config.scopus_url % "an_issn")
    end
  end


end