require 'rails_helper'

describe User do
  subject do
    User.create
  end

  let(:another_user) {
    User.create
  }

  let(:document) {
    SolrDocument.new(SolrDocument.unique_key => '1')
  }

  it "is valid" do
    expect(subject).to be_valid
  end

  it "has roles" do
    sup_role = Role.find_by_code('SUP')
    adm_role = Role.find_by_code('ADM')
    subject.roles << sup_role << adm_role
    expect(subject.roles).to include(sup_role, adm_role)
  end

  it "has own tags" do
    expect(subject.tags).to eq []
  end

  it "has own taggings" do
    expect(subject.taggings).to eq []
  end

  it "can tag a document" do
    subject.tag(document, 'a tag')
  end

  it "can list owned tags for document" do
    subject.tag(document, 'a tag')

    expect( subject.tags.map(&:name) ).to eq ['a tag']
    expect( subject.existing_tags_for(document).map(&:name) ).to eq ['a tag']
  end

  it "can list owned tags for document id" do
    subject.tag(document, 'a tag')

    expect( subject.tags.map(&:name) ).to eq ['a tag']
    expect( subject.existing_tags_for(document).map(&:name) ).to eq ['a tag']
  end

  it "can list owned tags for bookmark" do
    subject.tag(document, 'a tag')
    bookmark = subject.tags.find_by_name('a tag').bookmarks.first

    expect( subject.tags.map(&:name) ).to eq ['a tag']
    expect( subject.existing_tags_for(document).map(&:name) ).to eq ['a tag']
  end

  describe 'from Riyosha user data for DTU employee' do
    before(:each) do
      @user_data = {'id' => '12345',
                    'provider' => 'dtu',
                    'email' => 'mail@example.com',
                    'dtu' => {
                      'username'  => 'abcd',
                      'firstname' => 'Firstname',
                      'lastname'  => 'Lastname',
                      'user_type' => 'dtu_empl',
                      'matrikel_id' => '1234',
                    },
                    'address' => {
                      'line1'    => 'Address line 1',
                      'line2'    => 'Address line 2',
                      'line3'    => 'Address line 3',
                      'line4'    => 'Address line 4',
                      'line5'    => 'Address line 5',
                      'line6'    => 'Address line 6',
                      'zipcode'  => 'ZIP',
                      'cityname' => 'City',
                      'country'  => 'Country',
                   }}
      @provider = :cas
    end

    it "should be created correctly" do
      user = User.create_or_update_with_user_data(@provider, @user_data)
      expect(user.persisted?).to be_truthy
      expect(user.identifier).to eq @user_data['id']
      expect(user.dtu?).to be_truthy
      expect(user.employee?).to be_truthy
      expect(user.student?).to be_falsey

      expect(user.email).to eq 'mail@example.com'
      expect(user.name).to eq 'Firstname Lastname'
      expect(user.cwis).to eq '1234'

      expect(user.address['line1']).to eq 'Address line 1'
      expect(user.address['line2']).to eq 'Address line 2'
      expect(user.address['line3']).to eq 'Address line 3'
      expect(user.address['line4']).to eq 'Address line 4'
      expect(user.address['line5']).to eq 'Address line 5'
      expect(user.address['line6']).to eq 'Address line 6'
      expect(user.address['zipcode']).to eq 'ZIP'
      expect(user.address['cityname']).to eq 'City'
      expect(user.address['country']).to eq 'Country'
    end

    it "should be updated correctly" do
      user = User.create_or_update_with_user_data(@provider, @user_data)
      expect(user.email).to eq @user_data['email']

      @user_data['email'] = 'new_mail@example.com'
      updated_user = User.create_or_update_with_user_data(@provider, @user_data)
      expect(updated_user.email).to eq @user_data['email']
      expect(updated_user.id).to eq user.id
    end
  end

  describe "for anonymous user" do
    it "should be created correctly" do
      user = User.new
      expect(user.persisted?).to be_falsey
      expect(user.identifier).to be_nil
      expect(user.dtu?).to be_falsey
      expect(user.public?).to be_truthy

      expect(user.email).to be_nil
      expect(user.name).to eq 'Anonymous'

      expect(user.address).to be_nil
    end
  end
end
