require 'spec_helper'

describe ResolverController do
  describe '#index' do
    it 'redirects to the request assistance form' do
      get :index, :genre => 'article'
      should redirect_to new_assistance_request_path(:assistance_request => {}, :genre => :journal_article)
    end
  end
end
