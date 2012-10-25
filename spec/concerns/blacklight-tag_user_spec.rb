require 'spec_helper'

describe BlacklightTag::User do
  before(:each) do
    build_model :tagger do
      include BlacklightTag::User
    end
  end

  let (:tagger) {
    Tagger.new
  }

  it "has owned tags" do
    tagger.owned_tags.should == []
  end

  it "has subscribed tags" do
    tagger.subscribed_tags.should == []
  end

  it "can tag a document" do
    document = double("document")
    document.stub(:id).and_return(1)
    tagger.tag(document)
  end

  it "can list owned tags" do
    document = double("document")
    document.stub(:id).and_return(1)
    tagger.tag(document)
  end

end