require 'spec_helper'

describe ResolverController do
  describe '#index' do
    it 'renders the index template' do
      get :index
      should render_template :index
    end
  end
end
