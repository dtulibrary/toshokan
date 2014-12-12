# encoding: UTF-8
require 'rails_helper'

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
        expect(session.has_key?(:user_id)).to be_falsey
      end

      it 'redirects to cas logout' do
        delete 'destroy'
        expect(response).to redirect_to controller.logout_url
      end
    end

  end

  describe '#new' do
    it 'should redirect to cas' do
      get :new
      expect(response.code).to eq "302"
      expect(response.location).to include controller.omniauth_path(:cas)
    end

  end

  describe "#create" do

    context "when Riyosha api request works properly" do
      before(:each) do
        request.env["omniauth.auth"] = OmniAuth.mock_auth_for(:cas)
        @user_data = {'id' => 'abcd', 'email' => 'somebody@example.com'}
        expect(Riyosha).to receive(:find).with('abcd').and_return(@user_data)
      end

      it "should redirect to requested url on callback from CAS with proper auth hash" do
        post "create", :provider => :cas, :url => root_path

        expect(controller.session[:user_id]).to_not be_nil
        expect(response).to redirect_to(root_path)
      end

      it "should create a user from the user data" do
        post "create", :provider => :cas

        expect(User.find_by_identifier('abcd').user_data['email']).to eq @user_data['email']
      end

      it "should update the user data for an existing user" do
        post "create", :provider => :cas
        post "destroy"

        updated_user_data = {'id' => 'abcd', 'email' => 'updated@example.com'}
        expect(Riyosha).to receive(:find).with('abcd').and_return(updated_user_data)

        post "create", :provider => :cas
        expect( User.find_by_identifier('abcd').user_data['email'] ).to eq updated_user_data['email']
      end
    end

    context "when Riyosha api request fails " do
      before(:each) do
        request.env["omniauth.auth"] = OmniAuth.mock_auth_for(:cas)
      end
      context "and the user does not exist" do
        before(:each) do
          expect(Riyosha).to receive(:find).with('abcd').and_return(nil)
        end
        it "should not login" do
          post "create", :provider => :cas
          expect(controller.current_user).to_not be_authenticated
        end
        it "should display an error message" do
          post "create", :provider => :cas
          expect(controller.flash[:alert]).to_not be_blank
        end
      end
      context "and the user does exist" do
        before(:each) do
          @user_data = {'id' => 'abcd', 'email' => 'somebody@example.com'}
          expect(Riyosha).to receive(:find).with('abcd').and_return(@user_data)
        end
        it "should perform the login" do
          post "create", :provider => :cas
          expect(controller.current_user).to be_authenticated
        end
      end
    end
  end

  describe "#update" do
    before do
      @user = User.new(:identifier => '4321', :provider => 'cas',
        :user_data => {'id' => '4321', 'email' => 'somebody@example.com' })
      @user.roles = [Role.find_by_code('SUP')]
      @user.save!
      session[:user_id] = @user.id
      @other_user = User.create(:identifier => '1234', :provider => 'cas',
        :user_data => {'id' => '1234', 'email' => 'other@example.com' })
    end

    context 'when anonymous flag is set' do
      before do
        @params = {:anonymous => 'true'}
      end
      it 'should change to an anonymous user' do
        put :update, @params
        expect(session[:user_id]).to be_nil
        expect(session[:original_user_id]).to eq @user.id

        expect(controller.current_user).to_not be_authenticated
        expect(controller.current_user.roles).to be_empty
      end
      context 'and walk_in flag is set' do
        it 'should change to an anonymous user with walk_in abilities' do
          put :update, @params.merge({:walk_in => 'true'})
          expect(session[:user_id]).to be_nil
          expect(session[:original_user_id]).to eq @user.id

          expect(controller.current_user.walk_in).to be_truthy
        end
      end
    end

    context 'when student flag is set' do
      before do
        @params = {:student => 'true'}
      end
      it 'the current user should become a student without any roles' do
        expect(controller.current_user.roles).to_not be_empty
        put :update, @params
        expect(controller.current_user).to be_student
        expect(controller.current_user.roles).to be_empty
      end
    end

    context 'when employee flag is set' do
      before do
        @params = {:employee => 'true'}
      end
      it 'the current user should become an employee without any roles' do
        expect(controller.current_user.roles).to_not be_empty
        put :update, @params
        expect(controller.current_user).to be_employee
        expect(controller.current_user.roles).to be_empty
      end
    end

    context 'when identifier is supplied' do
      before do
        @params = {:identifier => @other_user.identifier }
      end

      it 'should change the user' do
        put :update, @params
        expect(session[:user_id]).to eq @other_user.id
        expect(session[:original_user_id]).to eq @user.id
      end

      context 'and walk_in flag is set' do
        it 'should change the user and give walk_in abilities' do
          put :update, @params.merge({:walk_in => 'true'})
          expect(session[:user_id]).to eq @other_user.id
          expect(session[:original_user_id]).to eq @user.id

          expect(controller.current_user.walk_in).to be_truthy
        end
      end

      context 'when request is not ajax' do
        it 'should redirect to root path' do
          put :update, @params
          expect(response).to redirect_to root_path
        end
      end
    end

    context 'when user is missing required role' do
      before do
        session[:user_id] = @other_user.id
        @params = { :identifier => @user.identifier }
      end

      it 'should not change the user' do
        put :update, @params
        expect(session[:user_id]).to eq @other_user.id
        expect(session[:original_user_id]).to be_nil
      end

      context 'when request is not ajax' do
        it 'should flash an error message' do
          put :update, @params
          expect(flash[:error]).to eq 'Not allowed'
        end

        it 'should redirect to root path' do
          put :update, @params
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when user can't' be found" do
      before do
        @params = { :identifier => 'i_am_an_alien' }
      end

      it 'should flash an error message' do
        put :update, @params
        expect(flash[:error]).to eq 'User not found'
      end

      context 'when request is not ajax' do
        it 'should redirect to root path' do
          put :update, @params
          expect(response).to redirect_to switch_user_path
          expect(flash[:error]).to eq "User not found"
        end
      end
    end
  end

  describe "#switch" do

    before do
      @user = login
    end

    it "should deny access for a user that doesn't have \"User Support\" role" do
      get :switch
      expect(response.response_code).to eq 401
    end

    it "should allow access for a user that has \"User Support\" role" do
      @user.roles << Role.find_by_code('SUP')
      get :switch
      expect(response.response_code).to eq 200
    end

    context 'when searching for a user' do
      before do
        @user = User.new(:identifier => '4321', :provider => 'cas',
          :user_data => {
            'email' => '12345@exmaple.com',
            'first_name' => 'Firstname',
            'last_name' => 'Lastname',
            'user_type' => 'student',
            'dtu' => {
              'email' => '12345@exmaple.com',
              'firstname' => 'Firstname',
              'lastname' => 'Lastname',
              'initials' => 'fl',
              'matrikel_id' => '12345',
              'user_type' => 'student'}})
        @user.roles = [Role.find_by_code('SUP')]
        @user.save!
        session[:user_id] = @user.id
        @other_user = User.create(:identifier => '1234', :provider => 'cas',
          :user_data => {
            'email' => '54321@example.com',
            'first_name' => 'Funny Name',
            'last_name' => 'Lastname',
            'user_type' => 'dtu_empl',
            'dtu' => {
              'email' => '54321@example.com',
              'firstname' => 'Funny Name ',
              'lastname' => 'Lastname',
              'initials' => 'fnl',
              'matrikel_id' => '54321',
              'user_type' => 'dtu_empl'}})
        @third_user = User.create(:identifier => '9876', :provider => 'cas',
          :user_data => {
            'email' => '98765@example.com',
            'first_name' => 'Another Name',
            'last_name' => 'Anotherlastname',
            'user_type' => 'dtu_empl',
            'dtu' => {
              'email' => '98765@example.com',
              'firstname' => 'Another Name ',
              'lastname' => 'Anotherlastname',
              'initials' => 'ana',
              'matrikel_id' => '98765',
              'user_type' => 'dtu_empl'}})

      end

      context 'and query matches one or more users' do
        it 'should assign a list of users' do
          get :switch, { :user_q => '12345' }
          found_users = assigns[:found_users]
          expect(found_users).to_not be_nil
        end

        it 'should include matched users in the assigned list' do
          get :switch, { :user_q => 'example.com' }
          found_users = assigns[:found_users]
          expect(found_users).to include(@other_user)
          expect(found_users).to include(@third_user)
        end

        it 'should not include the current user in the assigned list' do
          get :switch, { :user_q => 'lastname' }
          found_users = assigns[:found_users]
          expect(found_users).to_not include(@user)
        end
      end

      context 'and query has multiple tokens' do
        it 'should find only the user that matches all tokens' do
          get :switch, { :user_q => 'Lastname 54321@example.com' }
          found_users = assigns[:found_users]
          expect(found_users).to include(@other_user)
          expect(found_users.size).to eq 1
        end
      end

      context 'and query does not match a user' do
        it 'should assign an empty list of users' do
          get :switch, { :user_q => 'you cant find me' }
          found_users = assigns[:found_users]
          expect(found_users).to be_empty
        end
      end

      context 'and user is missing required role' do
        before do
          session[:user_id] = @other_user.id
          @params = { :user_q => 'bla' }
        end

        it 'should not allow listing users' do
          put :switch, @params
          expect(response.response_code).to eq 401
        end
      end

    end

  end

  describe "#logout_login_as_dtu" do

    it "redirects the user to logout with redirect params to login" do
      get :logout_login_as_dtu
      expect(response).to redirect_to controller.logout_login_as_dtu_url
    end
  end
end
