require "rails_helper"

describe Dtu::Metrics::AltmetricPresenter, type: :view do
  let(:document) { SolrDocument.new("doi_ss"=>["10.1016/j.tcs.2009.09.015"], "source_id_ss"=>[]) }
  let(:presenter) { described_class.new(document, view, {}) }

  describe 'render' do
    subject { presenter.render }
    it 'calls .altmetric_badge and returns that value' do
      expect(presenter).to receive(:altmetric_badge).and_return('the badge')
      expect(subject).to eq 'the badge'
    end
  end
  describe 'should_render?' do
    subject { presenter.should_render? }
    context 'when the document does not have any relevant identifiers' do
      let(:document) { SolrDocument.new("doi_ss"=>[], "source_id_ss"=>[]) }
      it { is_expected.to be false }
    end
    context 'when the document does have at least one relevant identifier' do
      let(:document) { SolrDocument.new("doi_ss"=>["10.1016/j.tcs.2009.09.015"], "source_id_ss"=>[]) }
      it { is_expected.to be true }
    end
  end
  describe '#altmetric_badge' do
    it 'renders altmetric badge for the document' do
      expect( presenter.altmetric_badge ).to have_xpath("//div[@class=\"altmetric-embed\" and @data-doi=\"10.1016/j.tcs.2009.09.015\"]")
    end
    it 'includes arxiv id when available' do
      document[:source_id_ss] = ["arxiv:oai:arXiv.org:0801.1253"]
      expect( presenter.altmetric_badge ).to have_xpath("//div[@class=\"altmetric-embed\" and @data-doi=\"10.1016/j.tcs.2009.09.015\"]")
    end
    it 'includes pmid when available' do
      document["source_id_ss"] = ["pubmed:21771119"]
      expect( presenter.altmetric_badge ).to have_xpath("//div[@class=\"altmetric-embed\" and @data-pmid=\"21771119\"]")

    end
    it "sets default data attributes" do
      expect( presenter.altmetric_badge ).to have_xpath("//div[@class=\"altmetric-embed\" and @data-badge-popover=\"left\" and @data-badge-type=\"donut\"]")
    end
    it "allows you to explicitly set the altmetric data attributes" do
      expect( presenter.altmetric_badge("data-badge-popover"=>"bottom" ) ).to have_xpath("//div[@class=\"altmetric-embed\" and @data-badge-popover=\"bottom\"]")
      expect( presenter.altmetric_badge("data-badge-type"=>"bar" ) ).to have_xpath("//div[@class=\"altmetric-embed\" and @data-badge-type=\"bar\"]")
    end
  end

end
