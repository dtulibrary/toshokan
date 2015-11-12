require "rails_helper"

describe BlacklightHelper do
  before do
    allow(helper).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
  end
  describe 'presenter' do
    subject { helper.presenter_class }
    it { is_expected.to eq Dtu::DocumentPresenter }
  end
end
