
require 'rails_helper'

describe SearchHistoryController do

  let!(:user) {
    login
  }

  let!(:ability) {
    ability = Object.new
    ability.extend CanCan::Ability
    allow(controller).to receive(:current_ability).and_return(ability)
    ability
  }

  describe "#index" do
    context "with ability to view search history" do
      before do
        ability.can :view, :search_history
        get :index
      end

      it 'assigns the alerts array' do
        expect(assigns(:searches)).to be_empty
      end

      it 'renders the index template' do        
        expect(response).to render_template 'index'
      end
    end

    context "without ability to view search history" do
      it 'redirects to Authentication Required' do
        get :index
        expect(response).to redirect_to authentication_required_url(:url => search_history_url)
      end
    end
  end

  describe "#save" do
    context "with ability to view search history" do
      before do
        ability.can :view, :search_history
        request.env["HTTP_REFERER"] = "where_i_came_from"
        create_search
        post :save, :id => 1        
      end

      it 'redirects to back' do        
        expect(response).to redirect_to("where_i_came_from")
      end
    end

    context "without ability to view search history" do
      it 'redirects to Authentication Required' do
        post :save, :id => 1
        expect(response).to be_redirect
      end
    end
  end

  describe "#forget" do
    context "with ability to view search history" do
      before do
        ability.can :view, :search_history
        request.env["HTTP_REFERER"] = "where_i_came_from"
        create_search
        delete :forget, :id => 1        
      end

      it 'redirects to back' do        
        expect(response).to redirect_to("where_i_came_from")
      end
    end

    context "without ability to view search history" do
      it 'redirects to Authentication Required' do
        delete :forget, :id => 1
        expect(response).to be_redirect
      end
    end
  end

  describe "#alert" do
    context "with ability to view search history" do
      before do
        ability.can :view, :search_history        
        request.env["HTTP_REFERER"] = "where_i_came_from"
        create_search
      end

      it 'redirects to back' do
        allow(Alert).to receive(:get).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
        allow(Alert).to receive(:post).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
        put :alert, :id => 1
        expect(response).to redirect_to("where_i_came_from")
      end

      it 'does not marked search as alerted if it can\'t be alerted' do
        allow(Alert).to receive(:get).and_return(double(:success? => false, :message => "Failure", :code => 500))        
        expect(Search.find_by_id(1).alerted).to_not be_truthy
      end

    end

    context "without ability to view search history" do
      it 'redirects to Authentication Required' do
        put :alert, :id => 1
        expect(response).to be_redirect
      end
    end
  end

  describe "#forget_alert" do
    context "with ability to view search history" do
      before do
        ability.can :view, :search_history        
        request.env["HTTP_REFERER"] = "where_i_came_from"
        search = create_search
        search.alerted = true
        search.save
      end

      it 'redirects to back' do
        allow(Alert).to receive(:get).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
        allow(Alert).to receive(:delete).and_return(double(:success? => true))        
        delete :forget_alert, :id => 1
        expect(response).to redirect_to("where_i_came_from")
      end

      it 'does not unmarked search as alerted when alert could not be deleted' do
        allow(Alert).to receive(:delete).and_return(double(:success? => false, :message => "Failure", :code => 500))
        expect(Search.find_by_id(1).alerted).to eq true
      end
    end

    context "without ability to view search history" do
      it 'redirects to Authentication Required' do
        delete :forget_alert, :id => 1
        expect(response).to be_redirect
      end
    end
  end

  describe "#destroy" do
    context "with ability to view search history" do
      before do
        ability.can :view, :search_history        
        request.env["HTTP_REFERER"] = "where_i_came_from"
        @search = create_search
      end

      it 'redirects to back' do        
        delete :destroy, :id => 1
        expect(response).to redirect_to("where_i_came_from")
      end

      it 'does not delete search when an associated alert could not be deleted' do
        @search.alerted = true
        @search.save        
        allow(Alert).to receive(:get).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
        allow(Alert).to receive(:delete).and_return(double(:success? => false, :message => "Failure", :code => 500))
        expect(Search.find_by_id(1)).to_not be_nil
      end
    end

    context "without ability to view search history" do
      it 'redirects to Authentication Required' do
        delete :destroy, :id => 1
        expect(response).to be_redirect
      end
    end
  end

  def create_search
    new_search = Search.create(:query_params => "test")      
    user.searches << new_search
    user.save      
    new_search
  end

end
