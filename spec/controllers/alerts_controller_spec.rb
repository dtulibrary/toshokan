require 'rails_helper'

describe AlertsController do

  let!(:user) {
    login
  }

  let!(:ability) {
    ability = Object.new
    ability.extend CanCan::Ability
    allow( controller ).to receive(:current_ability).and_return(ability)
    ability
  }

  describe "#index" do
    
    context "with ability to alert" do
      before do
        ability.can :alert, :journal
      end

      context "when alerts can be fetched" do

        before do
          @alert1 = Alert.new({:query => "test 1"})
          @alert2 = Alert.new({:query => "test 2"})
          allow( Alert ).to receive(:get).and_return(double(:success? => true, :body => [{"alert" => @alert1}, {"alert" => @alert2}].to_json))
          get :index
        end

        it 'assigns the alerts array' do
          expect(assigns(:alerts)).to_not be_empty
        end

        it 'renders the index template' do
          expect(response).to render_template 'index'
        end
      end

      context "when alerts can not be fetched" do

        before do
          allow( Alert ).to receive(:get).and_return(double(:success? => false, :message => "Failure", :code => 500))
          get :index
        end

        it "shows an error" do
          expect(flash[:error]).to_not be_nil
        end

        it "assigns an empty array" do
          expect(assigns(:alerts)).to be_empty
        end
      end
    end

    context "without ability to alert" do
      it "redirects to Authentication Required" do
        get :index
        expect( response ).to redirect_to authentication_required_url(:url => alerts_url)
      end
    end
  end

  describe "#show" do
    
    context "with ability to alert" do
      before do
        ability.can :alert, :journal        
      end

      context "when alert can be fetched" do

        before do
          allow( Alert ).to receive(:get).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
          get :show, id: 1        
        end

        it 'assigns the alert' do
          expect( assigns(:alert) ).to_not be_nil
        end

        it 'renders the index template' do
          expect(response).to render_template 'show'
        end
      end

      context "when alert can not be fetched" do
        before do
          allow( Alert ).to receive(:get).and_return(double(:success? => false, :message => "Failure", :code => 500))
          get :show, id: 1        
        end

        it "shows an error" do
          expect( flash[:error] ).to_not be_nil
        end

        it "assigns nil to alert" do
          expect( assigns(:alert) ).to be_nil
        end
      end
    end

    context "without ability to alert" do
      it 'redirects to Authentication Required' do
        get :show, id: 1
        expect( response ).to redirect_to authentication_required_url(:url => alert_url(:id => 1))
      end
    end
  end

  describe "#create" do
    context "with ability to alert" do
      before do
        ability.can :alert, :journal
        allow( Alert ).to receive(:post).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
        request.env["HTTP_REFERER"] = "where_i_came_from"
      end

      it 'creates the alert' do        
        post :create, alert: {}
        expect( assigns(:alert) ).to_not be_nil
      end

      it 'redirects to back' do
        post :create, alert: {}
        expect( response ).to redirect_to("where_i_came_from")
      end
    end

    context "without ability to alert" do
      it 'redirects to Authentication Required' do
        post :create, alert: nil
        expect( response ).to be_redirect
      end
    end    
  end

  describe "#destroy" do

    context 'with ability to alert' do
      before do
        ability.can :alert, :journal
        request.env["HTTP_REFERER"] = "where_i_came_from"
      end

      context 'when alert does not exist' do
        it 'shows an error' do
          allow( Alert ).to receive(:delete).and_return(double(:success? => false, :message => "Failure", :code => 404))
          delete :destroy, :id => 12345
          expect( flash[:error] ).to_not be_nil
        end
      end

      it 'redirects to back' do
        allow( Alert ).to receive(:delete).and_return(double(:success? => true))
        delete :destroy, :id => 12345
        expect( response ).to redirect_to("where_i_came_from")
      end

    end

    context 'without ability to alert' do
      it 'redirects to Authentication Required' do
        delete :destroy, :id => 12345
        expect( response ).to be_redirect
      end
    end
  end
  
end
