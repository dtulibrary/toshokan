require "rails_helper"

describe BlacklightHelper do
  before do
    allow(helper).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
  end
  describe 'presenter' do
    subject { helper.presenter(SolrDocument.new) }
    it { is_expected.to be_instance_of Dtu::DocumentPresenter }
  end
end
