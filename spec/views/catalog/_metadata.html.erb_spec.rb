require 'rails_helper'

describe 'catalog/_metadata.html.erb' do
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    expect(@controller).to receive(:current_ability).and_return(@ability)
  end

  let(:solr_document) {
    SolrDocument.new(SolrDocument.unique_key => '1234')
  }

  let(:synthetized_document) {
    SolrDocument.new
  }

  context 'when user cannot view detailed metadata' do
    before do
      @ability.cannot :view, :metadata
    end
    it 'renders nothing' do
      render :partial => 'catalog/metadata', :locals => { :document => solr_document }
      expect(rendered).to be_blank
    end
  end

  context 'when user can view detailed metadata' do
    before do
      @ability.can :view, :metadata
    end
    it 'renders nothing for synthetized document' do
      render :partial => 'catalog/metadata', :locals => { :document => synthetized_document }
      expect(rendered).to be_blank
    end

    it 'renders link to detailed metadata for real solr_document' do
      render :partial => 'catalog/metadata', :locals => { :document => solr_document }
      expect(rendered).to have_link('Open', metadata_path(:id => solr_document[SolrDocument.unique_key]))
    end
  end
end
