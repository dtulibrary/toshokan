require 'spec_helper'

describe Ability do
  context 'when application mode is dtu' do
    before do
      Rails.application.config.stub(:application_mode).and_return :dtu
    end

    context 'when user is anonymous' do
      before do
        @user = User.new 
        @ability = Ability.new @user
      end

      it 'cannot be anonymous' do
        @ability.can?(:be_anonymous, User).should be_false
      end
    end

    context 'when user is not anonymous' do
      before do
        @user = User.create! :provider => 'cas', :identifier => '1234'
        @ability = Ability.new @user
      end

      it 'can tag Solr documents' do
        @ability.can?(:tag, SolrDocument).should be_true
      end

      it 'can log out from DTU CAS' do
        @ability.can?(:logout_cas, User).should be_true
      end

      it 'cannot log in to DTU CAS' do
        @ability.can?(:login_cas, User).should be_false
      end

      it 'cannot log in to Velo' do
        @ability.can?(:login_velo, User).should be_false
      end

      it 'cannot log out from Velo' do
        @ability.can?(:logout_velo, User).should be_false
      end

      context 'when user has role ADM' do
        before do
          @user.roles << Role.find_by_code('ADM')
          @ability = Ability.new @user
        end

        it 'can edit users' do
          @ability.can?(:update, User).should be_true
        end
      end

      context 'when user has role SUP' do
        before do
          @user.roles << Role.find_by_code('SUP')
          @ability = Ability.new @user
        end

        it 'can switch user' do
          @ability.can?(:switch, User).should be_true
        end

        context 'when user is impersonating another user' do
          before do
            @user.impersonating = true
            @ability = Ability.new @user
          end

          it 'can switch back' do
            @ability.can?(:switch_back, User).should be_true
          end

          it 'cannot switch user' do
            @ability.can?(:switch, User).should be_false
          end
        end
      end

      context 'when user has role CAT' do
        before do
          @user.roles << Role.find_by_code('CAT')
          @ability = Ability.new @user
        end

      end

      context 'when user has role DAT' do
        before do
          @user.roles << Role.find_by_code('DAT')
          @ability = Ability.new @user
        end
      end
    end
  end

  context 'when application mode is dtu_kiosk' do
    before do
      Rails.application.config.stub(:application_mode).and_return :dtu_kiosk
    end

    context 'when user is anonymous' do
      before do
        @user = User.new :provider => 'cas', :identifier => '1234'
        @ability = Ability.new @user
      end

      it 'can be anonymous' do
        @ability.can?(:be_anonymous, User).should be_true
      end

      it 'can log into DTU CAS' do
        @ability.can?(:login_cas, User).should be_true
      end

      it 'cannot log into Velo' do
        @ability.can?(:login_velo, User).should be_false
      end
    end

    context 'when user is not anonymous' do
      before do
        @user = User.create! :provider => 'cas', :identifier => '1234'
        @ability = Ability.new @user
      end

      it 'can tag Solr documents' do
        @ability.can?(:tag, SolrDocument).should be_true
      end

      it 'can log out from DTU CAS' do
        @ability.can?(:logout_cas, User).should be_true
      end

      it 'cannot log in to DTU CAS' do
        @ability.can?(:login_cas, User).should be_false
      end

      it 'cannot log in to Velo' do
        @ability.can?(:login_velo, User).should be_false
      end

      it 'cannot log out from Velo' do
        @ability.can?(:logout_velo, User).should be_false
      end

      context 'when user has role ADM' do
        before do
          @user.roles << Role.find_by_code('ADM')
          @ability = Ability.new @user
        end

        it 'can tag Solr documents' do
          @ability.can?(:tag, SolrDocument).should be_true
        end

        it 'can update users' do
          @ability.can?(:update, User).should be_true
        end
      end

      context 'when user has role SUP' do
        before do
          @user.roles << Role.find_by_code('SUP')
          @ability = Ability.new @user
        end

        it 'can switch user' do
          @ability.can?(:switch, User).should be_true
        end

        context 'when user is impersonating another user' do
          before do
            @user.impersonating = true
            @ability = Ability.new @user
          end

          it 'can switch back' do
            @ability.can?(:switch_back, User).should be_true
          end

          it 'cannot switch user' do
            @ability.can?(:switch, User).should be_false
          end
        end
      end

      context 'when user has role CAT' do
        before do
          @user.roles << Role.find_by_code('CAT')
          @ability = Ability.new @user
        end

        # TODO: Add tests

      end

      context 'when user has role DAT' do
        before do
          @user.roles << Role.find_by_code('DAT')
          @ability = Ability.new @user
        end

        # TODO: Add tests

      end
    end
  end

  context 'when application mode is i4i' do
    before do
      Rails.application.config.stub(:application_mode).and_return :i4i
    end

    context 'when user is anonymous' do
      before do
        @user = User.new :provider => 'cas', :identifier => '1234'
        @ability = Ability.new @user
      end

      it 'can login to Velo' do
        @ability.can?(:login_velo, User).should be_true
      end

      it 'cannot tag Solr documents' do
        @ability.can?(:tag, SolrDocument).should be_false
      end

      it 'cannot login to DTU CAS' do
        @ability.can?(:login_cas, User).should be_false
      end

      it 'cannot logout from DTU CAS' do
        @ability.can?(:logout_cas, User).should be_false
      end

      it 'cannot switch user' do
        @ability.can?(:switch, User).should be_false
      end

      it 'cannot switch back' do
        @ability.can?(:switch_back, User).should be_false
      end

      it 'cannot update users' do
        @ability.can?(:update, User).should be_false
      end
    end

    context 'when user is not anonymous' do
      before do
        @user = User.create! :provider => 'cas', :identifier => '1234'
        @ability = Ability.new @user
      end
      
      it 'can tag Solr documents' do
        @ability.can?(:tag, SolrDocument).should be_true
      end

      it 'can logout from Velo' do
        @ability.can?(:logout_velo, User).should be_true
      end

      it 'cannot login to DTU CAS' do
        @ability.can?(:login_cas, User).should be_false
      end

      it 'cannot login to Velo' do
        @ability.can?(:login_velo, User).should be_false
      end

      context 'when user has role ADM' do
        before do
          @user.roles << Role.find_by_code('ADM')
          @ability = Ability.new @user
        end

        it 'can edit users' do
          @ability.can?(:update, User).should be_true
        end
      end

      context 'when user has role SUP' do
        before do
          @user.roles << Role.find_by_code('SUP')
          @ability = Ability.new @user
        end

        it 'can switch user' do
          @ability.can?(:switch, User).should be_true
        end
      end

      context 'when user has role DAT' do
        before do
          @user.roles << Role.find_by_code('DAT')
          @ability = Ability.new @user
        end

        it 'can view raw metadata' do
          @ability.can?(:view_raw, SolrDocument).should be_true
        end
      end

      context 'when user has role CAT' do
        before do
          @user.roles << Role.find_by_code('CAT')
          @ability = Ability.new @user
        end
      end
    end
  end

end
