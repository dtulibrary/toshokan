require 'spec_helper'

describe BlacklightTag::User do
  before(:each) do
    build_model :tagger do
      include BlacklightTag::User
    end
    build_model :document do
      include BlacklightTag::Taggable
    end
  end

  let (:user) {
    Tagger.create
  }

  let (:another_user) {
    Tagger.create
  }

  it "has own tags" do
    user.tags.should == []
  end

  it "has shared tags" do
    user.shared_tags.should == []
  end

  it "has own taggings" do
    user.taggings.should == []
  end

  it "has subscribed tags" do
    user.subscribed_tags.should == []
  end

  it "has subscribed taggings" do
    user.subscribed_taggings.should == []
  end

  it "can tag a document" do
    document = double("document")
    document.stub(:id).and_return(1)
    user.tag(document, 'a tag')
  end

  it "can list owned tags" do
    document = double("document")
    document.stub(:id).and_return(1)
    user.tag(document, 'a tag')

    user.tags.map(&:name).should == ['a tag']
    user.tags_for(document).map(&:name).should == ['a tag']
  end

  it "can subscribe to tags" do
    document = double("document")
    document.stub(:id).and_return(1)
    tag = user.tag(document, 'a tag')
    tag.share
    another_user.subscribe(tag)
  end

  it "can list subscribed tags" do
    document = double("document")
    document.stub(:id).and_return('1')
    tag = user.tag(document, 'a tag')
    tag.share
    another_user.subscribe(tag)

    debugger

    another_user.subscribed_tags_for(document).map(&:name).should == ['a tag']
    user.subscribed_tags_for(document).map(&:name).should == []
  end

end