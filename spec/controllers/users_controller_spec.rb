require 'rails_helper'

describe UsersController do
  before do 
    @user = login
    @ability = FactoryGirl.build :ability
    controller.stub(:current_ability).and_return @ability
  end

  describe '#index' do
    context 'with ability to update users' do
      before do
        @ability.can :update, User
      end

      it 'assigns all users' do
        get :index
        assigns(:all_users).size.should == User.count
      end

      it 'assigns all roles' do
        get :index
        assigns(:all_roles).size.should == Role.count
      end

      it 'renders index template' do
        get :index
        should render_template :index
      end
    end

    context 'without ability to update users' do
      it 'blocks access' do
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

    context 'with ability to update users' do
      before do
        @ability.can :update, User
      end

      context 'updating an existing user' do
        context 'with ajax parameter' do
          it 'updates user roles' do
            put :update, :id => @target_user.id, :role => @roles[0].id, :ajax => true
            @target_user.roles.should include *@roles[0]
          end
        
          it 'returns an HTTP 200' do
            put :update, :id => @target_user.id, :role => @roles[0].id, :ajax => true
            response.response_code.should == 200
          end
        end

        context 'without ajax parameter' do
          it 'updates user roles' do
            params = { :id => @target_user.id }
            @roles.each { |role| params[role.id.to_s] = '1' }
            put :update, params 
            @target_user.roles.should include *@roles
          end
        
          it 'redirects to index page' do
            put :update, :id => @target_user.id, :roles => @role_ids
            response.should redirect_to users_path
          end
        end
      end

      context 'updating a non-existing user' do
        it 'returns an HTTP 404' do
          put :update, :id => 'non-existing', :roles => @role_ids
          response.response_code.should == 404
        end
      end
    end

    context 'not having ability to update users' do
      context 'when referencing an existing user' do
        it 'blocks access' do
          put :update, :id => @target_user.id, :roles => @role_ids
          response.response_code.should == 401
        end
      end

      context 'when referencing a non-existing user' do
        it 'blocks access' do
          put :update, :id => 'non-existing', :roles => @role_ids
          response.response_code.should == 401
        end
      end
    end
  end

  describe '#destroy' do
    before do
      @role = Role.find_by_code 'SUP'
    end

    context 'with ability to update users' do
      before do
        @ability.can :update, User
      end

      context 'when referencing an existing user' do
        it 'removes user roles' do
          target_user = User.create! :identifier => '1234', :provider => 'cas'
          target_user.roles << @role
          delete :destroy, :id => target_user.id, :role => @role.id
          # Update target_user since its roles are cached
          target_user = User.find(target_user.id)
          target_user.roles.should_not include @role
        end
      end

      context 'when referencing a non-existing user' do
        it 'returns an HTTP 404' do
          delete :destroy, :id => 'non-existing', :role => @role.id
          response.response_code.should == 404
        end
      end
    end

    context 'without ability to update users' do
      context 'when referencing an existing user' do
        it 'blocks access' do
          target_user = User.create! :identifier => '1234', :provider => 'cas'
          delete :destroy, :id => target_user.id, :role => @role.id
          response.response_code.should == 401
        end
      end

      context 'when referencing a non-existing user' do
        it 'blocks access' do
          delete :destroy, :id => 'non-existing', :role => @role.id
          response.response_code.should == 401
        end
      end
    end
  end
end
