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
  it "renders snip_abstract" do
    expect(helper).to receive(:render_abstract_snippet).with(document)
    helper.snip_abstract(document:document)
    end
  describe "render_abstract_snippet" do
    let(:abstract) { "O desenvolvimento marsupial de Cymothoa liannae ocorre em 4 estádios. A distinção entre eles se baseia principalmente na aquisição e perda de cerdas nos apêndices, grau de desenvolvimento dos olhos, comprimento e numero de artículos da antena 2, transformações nas peças bucais (maxilas 1 e 2, palpo mandibular e maxilípede) e ornamentação do datilo dos pereopodes I-III. No ciclo de vida proposto para Cymothoa Liannae é relatada a dinamica das transformações que se processam durante seu desenvolvimento, abordando aspectos sobre fase de infestação e de inversão sexual. Esta espécie, tal como ocorre na maioria dos Cymothoidae é protandro-hermafrodita (cada animal passa por uma fase masculina antes de se tornar fêmea).<br>The marsupial development and the life oyole of Cymothoa liannae are described and discussed. This species is parasite on fishes (Chloroscombrus chrysurus) and. was collected on continental shelf of southeast Brazil from Rio de Janeiro to Rio Grande do Sul. Four distinct marsupial stages are recognize. The stage of infestation and the transition from male to female are also related." }
    let(:document_with_abstract) {SolrDocument.new("type_facet"=>"article", "abstract_ts"=>[abstract])}
    it "truncates abstract to 300 characters" do
      expect(helper.render_abstract_snippet(document_with_abstract) ).to eq(abstract.slice(0, 300) + '...')
    end
    context "when there is no abstract" do
      it "returns 'No abstract' if there is no abstract" do
        expect(helper.render_abstract_snippet(document) ).to eq "No abstract"
      end
    end
  end

  it "renders shortened_author_links" do
    document = SolrDocument.new("authors"=>authors)
    expected_append =  I18n.t('toshokan.catalog.shortened_list.et_al')
    rendered = helper.render_shortened_author_links(document:document, field:"authors")
    expect( rendered.split("; ").length ).to eq 4
    expect( rendered[-expected_append.length..rendered.length] ).to eq expected_append
  end
  describe "render_author_list" do
    it "renders author_list" do
      rendered = helper.render_author_list authors, nil
      authors.each do |author|
        expect(rendered).to have_link_to_search_for("l[author]", author)
      end
    end
    it "allows limiting list length" do
      expect( helper.render_author_list(authors, nil, {max_length:2}).split("; ").length ).to eq 2
      expect( helper.render_author_list(authors, nil, {max_length:3}).split("; ").length ).to eq 3
      expect( helper.render_author_list(authors, nil, {max_length:100}).split("; ").length ).to eq authors.length
    end
    it "allows appending a suffix at the end of the list" do
      to_append = "&tc.."
      rendered = helper.render_author_list authors, nil, {append:to_append}
      expect( rendered[-to_append.length..rendered.length] ).to eq to_append
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

end
