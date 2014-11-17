require 'rails_helper'

describe Alert do

  it_behaves_like "ActiveModel"

  before do
    @alert = Alert.new({:query => "123"})
  end

  describe "#save" do

    it "returns false on HTTP error" do
      Alert.stub(:post).and_return(double(:success? => false, :message => "Failure", :code => 500))      
      @alert.save.should eq false
    end

    it "returns false on timeout error" do
      Alert.stub(:post).and_raise(TimeoutError)
      @alert.save.should eq false
    end

    it "returns false when not found" do
      Alert.stub(:post).and_return(double(:success? => false, :message => "Failure", :code => 404))
      @alert.save.should eq false
    end
  end

  describe "#destroy" do

    it "returns true when deleting an alert" do
      Alert.stub(:delete).and_return(double(:success? => true))
      Alert.destroy("123").should eq true
    end

    it "returns false on HTTP error" do
      Alert.stub(:delete).and_return(double(:success? => false, :message => "Failure", :code => 500))
      Alert.destroy("123").should eq false
    end

    it "returns false on timeout error" do
      Alert.stub(:delete).and_raise(TimeoutError)
      Alert.destroy("123").should eq false
    end

    it "returns false when not found" do
      Alert.stub(:delete).and_return(double(:success? => false, :message => "Failure", :code => 404))
      Alert.destroy("123").should eq false
    end
  end

  describe "#all" do

    before do
      @user = User.create
    end

    it "returns a list of alerts" do
      @alert1 = Alert.new({:query => "test 1"})
      @alert2 = Alert.new({:query => "test 2"})
      Alert.stub(:get).and_return(double(:success? => true, :body => [{"alert" => @alert1}, {"alert" => @alert2}].to_json))
      Alert.all(@user, "journal").size.should eq 2
    end

    it "returns empty list on HTTP error" do
      Alert.stub(:get).and_return(double(:success? => false, :message => "Failure", :code => 500))
      Alert.all(@user, "journal").should be_nil
    end

    it "returns empty list on timeout error" do
      Alert.stub(:get).and_raise(TimeoutError)
      Alert.all(@user, "journal").should be_nil
    end
  end

  describe "#lookup" do

    it "returns the alert" do
      Alert.stub(:get).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
      Alert.lookup("123").should_not be_nil
    end

    it "returns nil on HTTP error" do
      Alert.stub(:get).and_return(double(:success? => false, :message => "Failure", :code => 500))
      Alert.lookup("123").should be_nil
    end

    it "returns nil on timeout error" do
      Alert.stub(:get).and_raise(TimeoutError)
      Alert.lookup("123").should be_nil
    end

    it "returns nil when not found" do
      Alert.stub(:get).and_return(double(:success? => false, :message => "Failure", :code => 404))
      Alert.lookup("123").should be_nil
    end
  end

  describe "#find" do

    before do
      @user = User.create
    end

    it "return the alert" do
      Alert.stub(:get).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
      Alert.find(@user, {:query => "123"}).should_not be_nil
    end

    it "returns nil on HTTP error" do
      Alert.stub(:get).and_return(double(:success? => false, :message => "Failure", :code => 500))
      Alert.find(@user, {:query => "123"}).should be_nil
    end

    it "returns nil on timeout error" do
      Alert.stub(:get).and_raise(TimeoutError)
      Alert.find(@user, {:query => "123"}).should be_nil
    end

    it "returns nil when not found" do
      Alert.stub(:get).and_return(double(:success? => false, :message => "Failure", :code => 404))
      Alert.find(@user, {:query => "123"}).should be_nil
    end
  end
end
