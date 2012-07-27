# encoding: utf-8

require 'spec_helper'

describe Dtubase::Account do
  before(:each) do
    fixture_path = File.join(RSpec.configuration.fixture_path, "dtubase")
    @abcd_response = double(:success? => true, :body => File.read(File.join(fixture_path, "abcd.xml")))
    @efgh_response = double(:success? => true, :body => File.read(File.join(fixture_path, "efgh.xml")))
    @ijkl_response = double(:success? => true, :body => File.read(File.join(fixture_path, "ijkl.xml")))
    @unknown_response = double(:success? => true, :body => %(<?xml version="1.0" encoding="utf-8"?><root></root>))
    @failure_response = double(:success? => false, :message => "Failure")
  end

  describe "#find_by_cwis" do

    it "returns a user for a valid cwis" do
      HTTParty.stub(:get).and_return(@abcd_response, @efgh_response, @ijkl_response)

      account = Dtubase::Account.find_by_cwis("12345");
      account.username.should == 'abcd'
      account.cwis.should == '12345'
      account.employee_profiles.size.should == 1

      account = Dtubase::Account.find_by_cwis('54321');
      account.username.should == 'efgh'
      account.cwis.should == '54321'
      account.employee_profiles.size.should == 2
      account.employee_profiles.first.active.should be_false
      account.employee_profiles[1].active.should be_true

      account = Dtubase::Account.find_by_cwis('67890');
      account.username.should == 'ijkl'
      account.cwis.should == '67890'
      account.employee_profiles.size.should == 1
      account.employee_profiles.first.kind.should == 'employee'
      account.student_profiles.size.should == 3
      account.student_profiles.first.kind.should == 'student'
      account.guest_profiles.size.should == 1
      account.guest_profiles.first.kind.should == 'guest'
    end

    it "returns nil for an invalid cwis" do
      HTTParty.stub(:get).and_return(@unknown_response)

      account = Dtubase::Account.find_by_cwis("unknown");
      account.should be_nil
    end

    it "throws exception on connection error" do
      HTTParty.stub(:get).and_return(@failure_response)

    end

  end

  describe "#find_by_username" do

    it "returns a user for a valid user name" do
      HTTParty.stub(:get).and_return(@abcd_response, @efgh_response, @ijkl_response)

      account = Dtubase::Account.find_by_username("abcd");
      account.username.should == 'abcd'
      account.cwis.should == '12345'
      account.employee_profiles.size.should == 1

      account = Dtubase::Account.find_by_username('efgh');
      account.username.should == 'efgh'
      account.cwis.should == '54321'
      account.employee_profiles.size.should == 2
      account.employee_profiles.first.active.should be_false
      account.employee_profiles[1].active.should be_true

      account = Dtubase::Account.find_by_username('ijkl');
      account.username.should == 'ijkl'
      account.cwis.should == '67890'
      account.employee_profiles.size.should == 1
      account.employee_profiles.first.kind.should == 'employee'
      account.student_profiles.size.should == 3
      account.student_profiles.first.kind.should == 'student'
      account.guest_profiles.size.should == 1
      account.guest_profiles.first.kind.should == 'guest'
    end

    it "returns nil for an invalid username" do
      HTTParty.stub(:get).and_return(@unknown_response)

      account = Dtubase::Account.find_by_username("asfjkasdfkajsdfakljsdhf");
      account.should be_nil
    end

    it "throws exception on connection error" do
      HTTParty.stub(:get).and_return(@failure_response)
    end

  end

end
