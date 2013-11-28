# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'cancan/matchers'

describe PagesController do
  describe '#authentication_required' do
    let(:params) {
      { :url => root_url }
    }

    context 'when logged in' do
      it 'should redirect directly to the giver url' do
        login
        get :authentication_required, params
        response.should redirect_to params[:url]
      end
    end

    context 'when not logged in' do
      it 'should render the template and return 403 Forbidden' do
        get :authentication_required, params
        response.should be_forbidden
        response.should render_template 'pages/authentication_required'
      end
    end
  end

end
