require 'spec_helper'

describe UsersController do
  before do 
    @user = login
  end

  describe '#index' do
    context 'having admin role' do
      before do
        @user.roles << Role.find_by_code('ADM')
      end

      # Maybe this is too brittle since users and roles
      # could be fetched in other ways
      it 'should fetch all users and all roles' do
        User.should_receive :all
        Role.should_receive :all
        get :index
      end

      it 'should render index template' do
        get :index
        should render_template :index
      end
    end

    context 'not having admin role' do
      it 'should block access' do
        get :index
        response.response_code.should == 401  
      end
    end
  end

  describe '#update' do
    before do
      @roles = ['DAT', 'SUP'].collect { |code| Role.find_by_code(code) }
      @role_ids = @roles.collect { |role| role.id }
      @target_user = User.create! :identifier => '1234', :provider => 'cas'
    end

    context 'having admin role' do
      before do
        logger.debug 'Add ADM role to user'
        @user.roles << Role.find_by_code('ADM')
      end

      context 'updating an existing user' do
        it 'should assign roles using non-ajax call' do
          params = { :id => @target_user.id }
          @roles.each { |role| params[role.id.to_s] = '1' }
          put :update, params 
          @target_user.roles.should include *@roles
        end

        it 'should assign roles using ajax call' do
          put :update, :id => @target_user.id, :role => @roles[0].id, :ajax => true
          @target_user.roles.should include *@roles[0]
        end

        it 'should redirect to index page for a non-ajax call' do
          put :update, :id => @target_user.id, :roles => @role_ids
          response.should redirect_to users_path
        end

        it 'should not redirect to index page for an ajax call' do
          put :update, :id => @target_user.id, :roles => @role_ids, :ajax => true
          response.should_not redirect_to users_path
        end
      end

      it 'should return an error when referencing a non-existing user' do
        put :update, :id => 'non-existing', :roles => @role_ids
        response.response_code.should == 404
      end
    end

    context 'not having admin role' do
      it 'should block access when referencing an existing user' do
        put :update, :id => @target_user.id, :roles => @role_ids
        response.response_code.should == 401
      end

      it 'should block access when referencing a non-existing user' do
        put :update, :id => 'non-existing', :roles => @role_ids
        response.response_code.should == 401
      end
    end
  end

  describe '#destroy' do
    before do
      @role = Role.find_by_code 'SUP'
    end

    context 'having admin role' do
      before do
        @user.roles << Role.find_by_code('ADM')
      end

      it 'should remove user roles when referencing an existing user' do
        target_user = User.create! :identifier => '1234', :provider => 'cas'
        target_user.roles << @role
        delete :destroy, :id => target_user.id, :role => @role.id
        # Update target_user since its roles are cached
        target_user = User.find(target_user.id)
        target_user.roles.should_not include @role
      end

      it 'should return an error when referencing a non-existing user' do
        delete :destroy, :id => 'non-existing', :role => @role.id
        response.response_code.should == 404
      end
    end

    context 'not having admin role' do
      it 'should block access when referencing an existing user' do
        target_user = User.create! :identifier => '1234', :provider => 'cas'
        delete :destroy, :id => target_user.id, :role => @role.id
        response.response_code.should == 401
      end

      it 'should block access when referencing a non-existing user' do
        delete :destroy, :id => 'non-existing', :role => @role.id
        response.response_code.should == 401
      end
    end
  end
end
