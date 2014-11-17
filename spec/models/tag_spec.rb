require 'rails_helper'

describe Tag do

  subject do
    Tag.create
  end

  it "is not valid without a name" do
    subject.should_not be_valid
  end

  it "is not valid with an empty name" do
    subject.name = ""
    subject.should_not be_valid
  end

  it "is not valid with a long name" do
    subject.name = "a" * 1000
    subject.should_not be_valid
  end

  it "is invalid if it starts with a reserved prefix" do
    subject.name = Tag.reserved_tag_prefix + "tag"
    subject.should_not be_valid
  end

  it "is valid with a reasonable name" do
    subject.name = "some %$%^**^**%@! tag"
    subject.should be_valid
  end

end
