require 'rails_helper'

describe Tag do

  subject do
    Tag.create
  end

  it "is not valid without a name" do
    expect(subject).to_not be_valid
  end

  it "is not valid with an empty name" do
    subject.name = ""
    expect(subject).to_not be_valid
  end

  it "is not valid with a long name" do
    subject.name = "a" * 1000
    expect(subject).to_not be_valid
  end

  it "is invalid if it starts with a reserved prefix" do
    subject.name = Tag.reserved_tag_prefix + "tag"
    expect(subject).to_not be_valid
  end

  it "is valid with a reasonable name" do
    subject.name = "some %$%^**^**%@! tag"
    expect(subject).to be_valid
  end

end
