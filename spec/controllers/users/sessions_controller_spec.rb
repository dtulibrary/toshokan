require 'spec_helper'

describe Users::SessionsController do

  describe '#destroy' do
    let :existing_user do
      user = User.new :identifier => '1234', :provider => 'cas'
      user.save!
      user
    end

    context 'with user id in session' do
      before do 
        session[:user_id] = existing_user.id
      end

      it 'removes the user id from the session' do
        delete 'destroy'
        session.has_key?(:user_id).should be_false
      end

      it 'redirects to the root path' do
        delete 'destroy'
        response.should redirect_to root_path
      end
    end

    context 'without user id in session' do
      it 'redirects to login' do
        delete 'destroy'
        response.should redirect_to new_user_session_path
      end
    end

  end

  it "should redirect to CAS if user is not authenticated" do
    controller.reset_session
    get "new"

    response.should redirect_to controller.omniauth_path(:cas)
  end

  it "should redirect to requested url on callback from CAS with proper auth hash" do
    account = Dtubase::Account.new
    account.cwis = '12345'
    account.username = 'abcd'
    Dtubase::Account.should_receive(:find_by_username).with('abcd').and_return(account)

    request.env["omniauth.auth"] = OmniAuth.mock_auth_for(:cas)
    return_url = "http://example.com/return_url"
    controller.session[:return_url] = return_url
    post "create", :provider => :cas

    controller.session[:user_id].should_not be_nil
    response.should redirect_to return_url
  end

  describe "update" do
    before do
      @user = User.new(:identifier => '4321', :provider => 'cas')
      @user.roles = [Role.find_by_code('SUP')]
      @user.save!
      session[:user_id] = @user.id
      @other_user = User.create(:username => 'test user name', :identifier => '1234', :provider => 'cas')
    end

    context 'when CWIS is supplied' do
      before do
        @params = {:user => {:identifier => '1234'}}
        account = Dtubase::Account.new
        account.cwis = '1234'
        Dtubase::Account.should_receive(:find_by_cwis).with('1234').and_return(account)
      end

      it 'should change the user' do
        put :update, @params
        session[:user_id].should == @other_user.id
        session[:original_user_id].should == @user.id
      end

      context 'when request is ajax' do
        before do
          @params[:ajax] = true
        end

        it 'should return status 200' do
          put :update, @params
          response.response_code.should == 200
        end
      end

      context 'when request is not ajax' do
        it 'should redirect to root path' do
          put :update, @params
          response.should redirect_to root_path
        end
      end
    end

    context 'when username is supplied' do
      before do
        @params = {:user => {:identifier => 'test user name'}}
        account = Dtubase::Account.new
        account.cwis = '1234'
        Dtubase::Account.should_receive(:find_by_cwis).with('test user name').and_return(nil)
        Dtubase::Account.should_receive(:find_by_username).with('test user name').and_return(account)
      end

      it 'should change the user' do
        put :update, @params
        session[:user_id].should == @other_user.id
        session[:original_user_id].should == @user.id
      end

      context 'when request is ajax' do
        before do
          @params[:ajax] = true
        end

        it 'should return status 200' do
          put :update, @params
          response.response_code.should == 200
        end
      end

      context 'when request is not ajax' do
        it 'should redirect to root path' do
          put :update, @params
          response.should redirect_to root_path
        end
      end
    end

    context 'when user is missing required role' do
      before do
        session[:user_id] = @other_user.id
        @params = { :user => { :identifier => '4321' }}
      end

      context 'when request is ajax' do
        before do
          @params[:ajax] = true
        end

        it 'should return status 403' do
          put :update, @params
          response.response_code.should == 403
        end
      end

      context 'when request is not ajax' do
        it 'should flash an error message' do
          put :update, @params
          flash[:error].should == 'Not allowed'
        end

        it 'should redirect to root path' do
          put :update, @params
          response.should redirect_to root_path
        end
      end
    end

    context "when cwis or username can't be found" do
      before do
        @params = {:user => {:identifier => 'test user name'}}
        account = Dtubase::Account.new
        account.cwis = '1234'
        Dtubase::Account.should_receive(:find_by_cwis).with('test user name').and_return(nil)
        Dtubase::Account.should_receive(:find_by_username).with('test user name').and_return(nil)
      end

      it 'should flash an error message' do
        put :update, @params
        flash[:error].should == 'User not found'
      end

      context 'when request is ajax' do
        before do
          @params[:ajax] = true
        end

        it 'should return status 404' do
          put :update, @params
          response.response_code.should == 404
        end

        it 'should render text containing flash message' do
          put :update, @params
          response.body.should == 'User not found'
        end
      end

      context 'when request is not ajax' do
        it 'should redirect to root path' do
          put :update, @params
          response.should redirect_to switch_user_path
        end
      end
    end
  end

  describe "#switch" do

    before do
      @user = login
    end

    it "should deny access for a user that doesn't have \"User Support\" role" do
      get 'switch'
      response.response_code.should == 401
    end

    it "should allow access for a user that has \"User Support\" role" do
      @user.roles << Role.find_by_code('SUP') 
      get 'switch'
      response.response_code.should == 200
    end

  end

end
