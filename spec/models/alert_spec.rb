require 'rails_helper'

describe Alert do

  it_behaves_like "ActiveModel"

  before do
    allow(Alert).to receive(:test_mode).and_return(false)
    @alert = Alert.new({:query => "123"})
  end

  describe "#save" do

    it "returns false on HTTP error" do
      allow(Alert).to receive(:post).and_return(double(:success? => false, :message => "Failure", :code => 500))      
      expect(@alert.save).to eq false
    end

    it "returns false on timeout error" do
      allow(Alert).to receive(:post).and_raise(TimeoutError)
      expect(@alert.save ).to eq false
    end

    it "returns false when not found" do
      allow(Alert).to receive(:post).and_return(double(:success? => false, :message => "Failure", :code => 404))
      expect(@alert.save).to eq false
    end
  end

  describe "#destroy" do

    it "returns true when deleting an alert" do
      allow(Alert).to receive(:delete).and_return(double(:success? => true))
      expect(Alert.destroy("123")).to eq true
    end

    it "returns false on HTTP error" do
      allow(Alert).to receive(:delete).and_return(double(:success? => false, :message => "Failure", :code => 500))
      expect(Alert.destroy("123")).to eq false
    end

    it "returns false on timeout error" do
      allow(Alert).to receive(:delete).and_raise(TimeoutError)
      expect(Alert.destroy("123")).to eq false
    end

    it "returns false when not found" do
      allow(Alert).to receive(:delete).and_return(double(:success? => false, :message => "Failure", :code => 404))
      expect(Alert.destroy("123")).to eq false
    end
  end

  describe "#all" do

    before do
      @user = User.create
    end

    it "returns a list of alerts" do
      @alert1 = Alert.new({:query => "test 1"})
      @alert2 = Alert.new({:query => "test 2"})
      allow(Alert).to receive(:get).and_return(double(:success? => true, :body => [{"alert" => @alert1}, {"alert" => @alert2}].to_json))
      expect( Alert.all(@user, "journal").size ).to eq 2
    end

    it "returns empty list on HTTP error" do
      allow(Alert).to receive(:get).and_return(double(:success? => false, :message => "Failure", :code => 500))
      expect( Alert.all(@user, "journal") ).to be_nil
    end

    it "returns empty list on timeout error" do
      allow(Alert).to receive(:get).and_raise(TimeoutError)
      expect( Alert.all(@user, "journal") ).to be_nil
    end
  end

  describe "#lookup" do

    it "returns the alert" do
      allow(Alert).to receive(:get).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
      expect(Alert.lookup("123")).to_not be_nil
    end

    it "returns nil on HTTP error" do
      allow(Alert).to receive(:get).and_return(double(:success? => false, :message => "Failure", :code => 500))
      expect(Alert.lookup("123")).to be_nil
    end

    it "returns nil on timeout error" do
      allow(Alert).to receive(:get).and_raise(TimeoutError)
      expect(Alert.lookup("123")).to be_nil
    end

    it "returns nil when not found" do
      allow(Alert).to receive(:get).and_return(double(:success? => false, :message => "Failure", :code => 404))
      expect(Alert.lookup("123")).to be_nil
    end
  end

  describe "#find" do

    before do
      @user = User.create
    end

    it "return the alert" do
      allow(Alert).to receive(:get).and_return(double(:success? => true, :body => {"alert" => Alert.new({:query => "test"})}.to_json))
      expect( Alert.find(@user, {:query => "123"}) ).to_not be_nil
    end

    it "returns nil on HTTP error" do
      allow(Alert).to receive(:get).and_return(double(:success? => false, :message => "Failure", :code => 500))
      expect( Alert.find(@user, {:query => "123"}) ).to be_nil
    end

    it "returns nil on timeout error" do
      allow(Alert).to receive(:get).and_raise(TimeoutError)
      expect( Alert.find(@user, {:query => "123"}) ).to be_nil
    end

    it "returns nil when not found" do
      allow(Alert).to receive(:get).and_return(double(:success? => false, :message => "Failure", :code => 404))
      expect( Alert.find(@user, {:query => "123"}) ).to be_nil
    end
  end
end
