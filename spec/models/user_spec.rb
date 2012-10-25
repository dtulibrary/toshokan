require 'spec_helper'

describe User do

  it "should be valid" do
    subject.should be_valid
  end

  it "has tags" do
    subject.tags.should == []
  end

  it "has subscribed tags" do
    subject.subscribed_tags.should == []
  end

  it "can tag document" do
    document = double("document")
  end

  it "should have roles" do
    sup_role = Role.find_by_code('SUP')
    adm_role = Role.find_by_code('ADM')
    subject.roles << sup_role << adm_role
    subject.roles.should include(sup_role, adm_role)
  end

  describe 'from Account' do
    before (:each) do
      @account = Hashie::Mash.new({:cwis => '12345',
                                   :username => 'abcd',
                                   :firstname => 'Firstname',
                                   :lastname => 'Lastname',
                                   :email => 'mail@example.com',
                                   :profiles => [{:kind => 'employee',
                                                  :id => '1234',
                                                  :org_id => '12',
                                                  :email => 'mail@example.com',
                                                  :active => true
                                                  }]})
      @provider = :cas
    end

    it "should be created correctly" do
      user = User.create_or_update_with_account(@provider, @account)
      user.persisted?.should be_true
      user.identifier.should == @account.cwis
      user.username.should == @account.username
      user.firstname.should == @account.firstname
      user.active?.should be_true
      user.employee?.should be_true
      user.student?.should be_false
      user.guest?.should be_false
    end

    it "should be updated correctly" do
      user = User.create_or_update_with_account(@provider, @account)
      user.email.should == @account.email

      @account.email = 'new_mail@example.com'
      updated_user = User.create_or_update_with_account(@provider, @account)
      updated_user.email = @account.email
      updated_user.id.should == user.id
    end

    describe "with Profiles" do
      it "should create the right number of profiles" do
        user = User.create_or_update_with_account(@provider, @account)
        user.profiles.size.should == 1

        user.profiles.first.email.should == 'mail@example.com'
        user.profiles.first.active?.should be_true
      end

      it "should update the right number of profiles" do
        @account.profiles << Hashie::Mash.new({:kind => 'student',
                                               :id => '2345',
                                               :email => 'seg@example.com',
                                               :active => false})

        user = User.create_or_update_with_account(@provider, @account)
        user.profiles.size.should == 2
        user.active_profiles.size.should == 1

        user.student_profiles.size.should == 1
        user.guest_profiles.size.should == 0
        user.employee_profiles.size.should == 1

        user.active_student_profiles.size.should == 0
        user.active_guest_profiles.size.should == 0
        user.active_employee_profiles.size.should == 1

        user.employee?.should be_true
        user.student?.should be_false
        user.guest?.should be_false
 
        @account.profiles = @account.profiles[1..1]
        user = User.create_or_update_with_account(@provider, @account)
        user.profiles.size.should == 1
      end
    end

  end
end
