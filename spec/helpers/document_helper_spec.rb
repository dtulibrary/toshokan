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
    it "returns an empty string if params[:resolve] is set" do
      allow(helper).to receive(:params).and_return({resolve:["foo"]})
      expect(helper.render_link_rel_alternates(document)).to eq("")
    end
    it "renders links (default blacklight behavior) if params[:resolve] is empty" do
      # Confirm that default behavior is triggered.
      # Actual test coverage for this behavior is in blacklight.
      allow(helper).to receive(:polymorphic_url).and_return("/link/to/format")
      tmp_value = Capybara.ignore_hidden_elements
      Capybara.ignore_hidden_elements = false
      expect(helper.render_link_rel_alternates(document)).to have_selector("link")
      allow(helper).to receive(:params).and_return({resolve:[]})
      expect(helper.render_link_rel_alternates(document)).to have_selector("link")
      Capybara.ignore_hidden_elements = tmp_value
    end
  end
  describe "render_abstract_with_highlights" do
    let(:abstract) { "O desenvolvimento marsupial de Cymothoa liannae ocorre em 4 estádios. A distinção entre eles se baseia principalmente na aquisição e perda de cerdas nos apêndices, grau de desenvolvimento dos olhos, comprimento e numero de artículos da antena 2, transformações nas peças bucais (maxilas 1 e 2, palpo mandibular e maxilípede) e ornamentação do datilo dos pereopodes I-III. No ciclo de vida proposto para Cymothoa Liannae é relatada a dinamica das transformações que se processam durante seu desenvolvimento, abordando aspectos sobre fase de infestação e de inversão sexual. Esta espécie, tal como ocorre na maioria dos Cymothoidae é protandro-hermafrodita (cada animal passa por uma fase masculina antes de se tornar fêmea).<br>The marsupial development and the life oyole of Cymothoa liannae are described and discussed. This species is parasite on fishes (Chloroscombrus chrysurus) and. was collected on continental shelf of southeast Brazil from Rio de Janeiro to Rio Grande do Sul. Four distinct marsupial stages are recognize. The stage of infestation and the transition from male to female are also related." }
    let(:truncated_abstract) { truncate(abstract, length: 300, separator:'') }
    let(:document_with_abstract) {SolrDocument.new("type_facet"=>"article", "abstract_ts"=>[abstract])}
    let(:document) { document_with_abstract }
    let(:highlights) { nil }
    let(:short_highlight) { 'The organically produced feed contained sustainable certified fish meal (45%), fish oil (14%), and organic certified wheat'}
    let(:long_highlight) { abstract.gsub('desenvolvimento', '<em>desenvolvimento</em>')}
    let(:rendered) { helper.render_abstract_with_highlights(document:document) }
    before do
      allow(document).to receive(:has_highlight_field?).with('abstract_ts').and_return( !highlights.nil? )
      allow(document).to receive(:highlight_field).with('abstract_ts').and_return(highlights)
    end
    describe 'when the first highlight is > 290 characters' do
      let(:highlights) { [long_highlight] }
      it 'throws away the stored value from solr, using the first highlight instead' do
        expect(helper).to receive(:render_snippets).with([long_highlight]).and_return(['rendered snippets'])
        expect(rendered).to eq(['rendered snippets'])
      end
    end
    describe 'when the first highlight is < 290 characters' do
      let(:highlights) { [short_highlight] }
      it 'keeps the stored value from solr, displaying all highlights after it' do
        expect(helper).to receive(:render_snippets).with([truncated_abstract, short_highlight]).and_return(['rendered snippets'])
        expect(rendered).to eq(['rendered snippets'])
      end
    end
    describe 'when there are multiple highlights' do
      let(:highlights) { [long_highlight, short_highlight] }
      it 'renders a snippet for each highlight' do
        expect(helper).to receive(:render_snippets).with([long_highlight,short_highlight]).and_return(['rendered snippets'])
        expect(rendered).to eq(['rendered snippets'])
      end
    end
    describe 'when there are not highlights' do
      let(:highlights) { nil }
      let(:document) { document_with_abstract }
      it "truncates abstract to 300 characters" do
        expect(helper).to receive(:render_snippets).with([truncated_abstract]).and_return(['rendered snippets'])
        expect(rendered).to eq(['rendered snippets'])
      end
    end
    context "when there is no abstract" do
      let(:document) {SolrDocument.new(issn_ss:"aa56T87")}
      it "returns 'No abstract' if there is no abstract" do
        expect(helper).to receive(:render_snippets).with(["No abstract"]).and_return(["No abstract"])
        expect(rendered).to eq ["No abstract"]
      end
    end
  end
  describe 'render_snippets' do
    it 'renders the snippets as div tags' do
      rendered = helper.render_snippets(['one', 'two'])
      expect(rendered.count).to eq 2
      expect(rendered.first).to have_selector('div.snippet', text: 'one...')
      expect(rendered.first).to_not have_selector('.supplemental')
      expect(rendered[1]).to have_selector('div.snippet.supplemental', text: '...two...')
    end
    it 'does not add elipses if they are already there' do
      rendered = helper.render_snippets(['do not duplicate my elipsis...', 'nor my elipsis...', '...nor mine'])
      # you should never see extra elipses
      rendered.each {|tag| expect(tag).to_not have_content('.....') }
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
    let(:document) { SolrDocument.new("authors"=>authors) }
    subject { helper.render_shortened_author_links(document:document, field:"authors") }
    it "renders shortened_author_links" do
      allow(helper).to receive(:highlighted_author_list).and_return(authors)
      expected_append =  I18n.t('toshokan.catalog.shortened_list.et_al')
      expect( subject.split("; ").length ).to eq 4
      expect( subject[-expected_append.length..subject.length] ).to eq expected_append
    end
  end
  describe 'highlighted_author_list' do
    let(:document) { SolrDocument.new("authors"=>authors) }
    let(:highlights) { ['<em>Charlotte Brontë</em>'] }
    subject { helper.highlighted_author_list(document:document, field:"authors") }
    before do
      allow(document).to receive(:has_highlight_field?).with('authors').and_return true
      allow(document).to receive(:highlight_field).with('authors').and_return highlights
    end
    it "replaces author names with their highlighted versions" do
      expect(subject).to eq ["Marie Shelley", "Emily Brontë", "<em>Charlotte Brontë</em>", "George Eliot"]
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