require "rails_helper"

describe DocumentHelper do
  let(:document) {SolrDocument.new(issn_ss:"aa56T87")}
  let(:authors) { ["Marie Shelley", "Emily Brontë", "Charlotte Brontë", "George Eliot"] }
  let(:authors_with_affiliations) { "[{\"aff\":\"none\",\"au\":[\"Zhusubaliyev, Z.T.\"]},{\"aff\":\"Department of Structural Engineering and Materials, Technical University of Denmark\",\"au\":[\"Laugesen, Jakob Lund\"]},{\"aff\":\"Department of Physics, Technical University of Denmark\",\"au\":[\"Mosekilde, Erik\"]}]" }

  it "renders type using values from locale file" do
    document =  SolrDocument.new("type_facet"=>"article")
    expect( render_type(document:document, field:"type_facet") ).to eq(I18n.t("toshokan.catalog.formats.article"))
  end
  describe "render_link_rel_alternates" do
    let(:document_presenter) { CatalogController.blacklight_config.document_presenter_class.new(document, view) }
    subject { helper.render_link_rel_alternates(document) }
    context "if params[:resolve] is set" do
      before do
        allow(helper).to receive(:params).and_return({resolve:["foo"]})
      end
      it "returns an empty string" do
        expect(subject).to eq("")
      end
    end
    context "if params resolve is blank" do
      before do
        allow(helper).to receive(:params).and_return({resolve: double(blank?:true)})
      end
      it "triggers the default blacklight behavior" do
        # The default behavior (triggered by calling `super`) calls presenter(document).link_rel_alternates
        allow(helper).to receive(:presenter).and_return(document_presenter)
        expect(document_presenter).to receive(:link_rel_alternates).with({})
        subject
      end
    end
  end

  describe "render_author_links" do
    it "handles authors with affiliations" do
      document = SolrDocument.new("authors"=>authors, "author_affiliation_ssf"=>[authors_with_affiliations])
      expect(helper).to receive(:render_author_list).with(authors_with_affiliations, {:author_with_affiliation => true})
      helper.render_author_links(document:document, field:"authors")
    end
    it "handles authors without affiliations" do
      document = SolrDocument.new("authors"=>authors)
      expect(helper).to receive(:render_author_list).with(authors)
      helper.render_author_links(document:document, field:"authors")
    end
  end

  describe 'render_shortened_author_links' do
    let(:document) { SolrDocument.new("authors_ts"=>authors) }
    subject { helper.render_shortened_author_links(document:document, field:"authors_ts") }
    before do
      allow(document).to receive(:has_highlight_field?).with('authors_ts').and_return(true)
      allow(document).to receive(:highlight_field).with('authors_ts').and_return(['<em>Emily Brontë</em>'])
    end
    it "renders first three author links including highlighted hits" do
      allow(helper).to receive(:highlighted_author_list).and_return(authors)
      expected_append =  I18n.t('toshokan.catalog.shortened_list.et_al')
      expect( subject.split("; ").length ).to eq 4
      expect(subject).to have_css('.author a', text: 'Marie Shelley')
      expect(subject).to have_css('.author a', text: '<em>Emily Brontë</em>')
      expect(subject).to have_css('.author a', text: 'Charlotte Brontë')
      expect(subject).to_not have_css('.author a', text: 'George Eliot')
      expect( subject[-expected_append.length..subject.length] ).to eq expected_append
    end
  end

  describe "render_author_list" do
    it "renders author_list" do
      rendered = helper.render_author_list authors
      authors.each do |author|
        expect(rendered).to have_link_to_search_for("l[author]", author)
      end
    end
    it "allows limiting list length" do
      expect( helper.render_author_list(authors, {max_length:2}).split("; ").length ).to eq 2
      expect( helper.render_author_list(authors, {max_length:3}).split("; ").length ).to eq 3
      expect( helper.render_author_list(authors, {max_length:100}).split("; ").length ).to eq authors.length
    end
    it "allows appending a suffix at the end of the list" do
      to_append = "&tc.."
      rendered = helper.render_author_list authors, {append:to_append}
      expect( rendered[-to_append.length..rendered.length] ).to eq to_append
    end
    context "when authors have affiliations" do
      it "renders the author list with links to find other material by each author" do
        rendered = helper.render_author_list authors_with_affiliations, {:author_with_affiliation => true}
        expect(rendered).to have_link_to_search_for("l[author]", "Zhusubaliyev, Z.T.")
        expect(rendered).to have_link_to_search_for("l[author]", "Laugesen, Jakob Lund")
        expect(rendered).to have_link_to_search_for("l[author]", "Mosekilde, Erik")
      end
    end
  end
  it "renders author_link" do
    expect(helper.render_author_link("Joan Didion")).to have_link("Joan Didion", :href=>catalog_index_path("l[author]"=>"Joan Didion"))
  end
  it "renders keyword_links"  do
    document = SolrDocument.new("keywords"=>["love", "joy", "equanimity", "compassion"])
    rendered = helper.render_keyword_links(document:document, field:"keywords")
    ["love", "joy", "equanimity", "compassion"].each do |keyword|
      expect(rendered).to have_link_to_search_for("l[subject]", keyword)
    end
  end
  describe "render_affiliations" do
    context "when author_affiliation_ssf is set" do
      it "includes affiliation info" do
        document = SolrDocument.new("author_affiliation_ssf"=>[authors_with_affiliations])
        expect(helper.render_affiliations(document:document,field:"authors")).to eq("<span><span>none</span><sup>1</sup></span><br><span><span>Department of Structural Engineering and Materials, Technical University of Denmark</span><sup>2</sup></span><br><span><span>Department of Physics, Technical University of Denmark</span><sup>3</sup></span>")
      end
    end
    it "defaults to wrapping the author values in <span> elements"  do
      document = SolrDocument.new("authors"=>authors)
      expect(helper.render_affiliations(document:document,field:"authors")).to eq("<span>Marie Shelley</span><br><span>Emily Brontë</span><br><span>Charlotte Brontë</span><br><span>George Eliot</span>")
    end
  end

end