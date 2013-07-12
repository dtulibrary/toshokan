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

      it 'redirects to cas logout' do
        delete 'destroy'
        response.should redirect_to controller.logout_url
      end
    end

  end

  describe '#new' do
    it 'should redirect to cas' do
      get :new
      response.should redirect_to controller.omniauth_path(:cas)
    end

  end

  describe "#create" do
    before(:each) do
      request.env["omniauth.auth"] = OmniAuth.mock_auth_for(:cas)
      @return_url = "http://example.com/return_url"
      controller.session[:return_url] = @return_url

      @user_data = {'id' => 'abcd', 'email' => 'somebody@example.com'}
      Riyosha
        .should_receive(:find).with('abcd')
        .and_return(@user_data)
    end

    it "should redirect to requested url on callback from CAS with proper auth hash" do
      post "create", :provider => :cas

      controller.session[:user_id].should_not be_nil
      response.should redirect_to @return_url
    end

    it "should create a user from the user data" do
      post "create", :provider => :cas

      User.find_by_identifier('abcd').user_data['email'].should eq @user_data['email']
    end

    it "should update the user data" do
      post "create", :provider => :cas

      updated_user_data = {'id' => 'abcd', 'email' => 'updated@example.com'}
      Riyosha
        .should_receive(:find).with('abcd')
        .and_return(updated_user_data)

      post "create", :provider => :cas
      User.find_by_identifier('abcd').user_data['email'].should eq updated_user_data['email']
    end
  end

  describe "update" do
    before do
      @user = User.new(:identifier => '4321', :provider => 'cas')
      @user.roles = [Role.find_by_code('SUP')]
      @user.save!
      session[:user_id] = @user.id
      @other_user = User.create(:identifier => '1234', :provider => 'cas')
    end

    context 'when identifier is supplied' do
      before do
        @params = {:user => {:identifier => @other_user.identifier }}
        user_data = {'id' => @other_user.identifier}
        Riyosha.should_receive(:find).with(@other_user.identifier).and_return(user_data)
      end

      it 'should change the user' do
        put :update, @params
        session[:user_id].should eq @other_user.id
        session[:original_user_id].should eq @user.id
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
        @params = { :user => { :identifier => @user.identifier }}
      end

      it 'should not change the user' do
        put :update, @params
        session[:user_id].should eq @other_user.id
        session[:original_user_id].should be_nil
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

    context "when user can't' be found" do
      before do
        @params = {:user => {:identifier => 'i_am_an_alien'}}
        Riyosha.should_receive(:find).with('i_am_an_alien').and_return(nil)
      end

      it 'should flash an error message' do
        put :update, @params
        flash[:error].should == 'User not found'
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
