
require 'spec_helper'

describe AlertsController do

  let!(:user) {
    login
  }

  let!(:ability) {
    ability = Object.new
    ability.extend CanCan::Ability
    controller.stub(:current_ability).and_return(ability)
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
          Alert.stub(:get).and_return(double(:success? => true, :body => [{"alert" => @alert1}, {"alert" => @alert2}].to_json))
          get :index
        end

        it 'assigns the alerts array' do
          assigns(:alerts).should_not be_empty
        end

        it 'renders the index template' do        
          should render_template 'index'
        end
      end

      context "when alerts can not be fetched" do

        before do
          Alert.stub(:get).and_return(double(:success? => false, :message => "Failure", :code => 500))
          get :index
        end

        it "shows an error" do
          flash[:error].should_not be_nil
        end

        it "assigns an empty array" do
          assigns(:alerts).should be_empty
        end
      end
    end

    context "without ability to alert" do
      it "returns 404" do
        get :index
        response.response_code.should == 404
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
          Alert.stub(:get).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
          get :show, id: 1        
        end

        it 'assigns the alert' do        
          assigns(:alert).should_not be_nil
        end

        it 'renders the index template' do
          should render_template 'show'
        end
      end

      context "when alert can not be fetched" do
        before do
          Alert.stub(:get).and_return(double(:success? => false, :message => "Failure", :code => 500))
          get :show, id: 1        
        end

        it "shows an error" do
          flash[:error].should_not be_nil
        end

        it "assigns nil to alert" do
          assigns(:alert).should be_nil
        end
      end
    end

    context "without ability to alert" do
      it "returns 404" do
        get :show, id: 1
        response.response_code.should == 404
      end
    end
  end

  describe "#create" do
    context "with ability to alert" do
      before do
        ability.can :alert, :journal
        Alert.stub(:post).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
        request.env["HTTP_REFERER"] = "where_i_came_from"
      end

      it 'creates the alert' do        
        post :create, alert: {}
        assigns(:alert).should_not be_nil
      end

      it 'redirects to back' do
        post :create, alert: {}
        response.should redirect_to("where_i_came_from")
      end
    end

    context "without ability to alert" do
      it "returns 404" do
        post :create, alert: nil
        response.response_code.should == 404
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
          delete :destroy, :id => 12345          
          flash[:error].should_not be_nil
        end
      end

      it 'redirects to back' do
        delete :destroy, :id => 12345
        response.should redirect_to("where_i_came_from")
      end

    end

    context 'without ability to alert' do
      it 'returns an HTTP 404' do
        delete :destroy, :id => 12345
        response.response_code.should == 404
      end
    end
  end
  
end