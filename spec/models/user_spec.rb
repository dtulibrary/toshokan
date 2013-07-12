require 'spec_helper'

describe User do
  subject do
    User.create
  end

  let(:another_user) {
    User.create
  }

  let(:document) {
    d = double("document")
    d.stub(:id).and_return("1")
    d
  }

  it "is valid" do
    subject.should be_valid
  end

  it "has roles" do
    sup_role = Role.find_by_code('SUP')
    adm_role = Role.find_by_code('ADM')
    subject.roles << sup_role << adm_role
    subject.roles.should include(sup_role, adm_role)
  end

  it "has own tags" do
    subject.tags.should eq []
  end

  it "has own taggings" do
    subject.taggings.should eq []
  end

  it "can tag a document" do
    subject.tag(document, 'a tag')
  end

  it "can list owned tags for document" do
    subject.tag(document, 'a tag')

    subject.tags.map(&:name).should eq ['a tag']
    subject.tags_for(document).map(&:name).should eq ['a tag']
  end

  it "can list owned tags for document id" do
    subject.tag(document, 'a tag')

    subject.tags.map(&:name).should eq ['a tag']
    subject.tags_for(document.id).map(&:name).should eq ['a tag']
  end

  it "can list owned tags for bookmark" do
    subject.tag(document, 'a tag')
    bookmark = subject.tags.find_by_name('a tag').bookmarks.first

    subject.tags.map(&:name).should eq ['a tag']
    subject.tags_for(bookmark).map(&:name).should eq ['a tag']
  end

  describe 'from Riyosha user data' do
    before(:each) do
      @user_data = {'id' => '12345',
                    'provider' => 'dtu',
                    'email' => 'mail@example.com',
                    'dtu' => {
                      'username'  => 'abcd',
                      'firstname' => 'Firstname',
                      'lastname'  => 'Lastname',
                      'type'      => 'employee'
                   }}
      @provider = :cas
    end

    it "should be created correctly" do
      user = User.create_or_update_with_user_data(@provider, @user_data)
      user.persisted?.should be_true
      user.identifier.should eq @user_data['id']
      user.dtu?.should be_true
    end

    it "should be updated correctly" do
      user = User.create_or_update_with_user_data(@provider, @user_data)
      user.email.should eq @user_data['email']

      @user_data['email'] = 'new_mail@example.com'
      updated_user = User.create_or_update_with_user_data(@provider, @user_data)
      updated_user.email.should eq @user_data['email']
      updated_user.id.should eq user.id
    end

  end
end
