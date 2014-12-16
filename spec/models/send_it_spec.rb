require 'rails_helper'

describe SendIt do
  context 'when in test_mode' do
    it 'does not call post on HTTParty' do
      expect(SendIt).to receive(:test_mode?).and_return(true)
      expect(HTTParty).not_to receive(:post)
      SendIt.send_mail 'template', {}
    end
  end

  context 'when HTTParty raises error' do
    it 're-raises the error' do
      allow(SendIt).to receive(:test_mode?).and_return(false)
      expect(HTTParty).to receive(:post).and_raise('an error')
      expect { SendIt.send_mail 'template', {} }.to raise_error('an error')
    end
  end

  context 'when http request fails' do
    let(:failed_response) {
      Struct.new(:code).new(400)
    }

    it 'raises an error' do
      allow(SendIt).to receive(:test_mode?).and_return(false)
      expect(HTTParty).to receive(:post).and_return(failed_response)
      expect { SendIt.send_mail 'template', {} }.to raise_error
    end
  end

  context 'when sending feedback email' do
    before do
      allow(SendIt).to receive(:test_mode?).and_return(false)
      allow(SendIt).to receive(:feedback_mail).and_return('to@example.com')
    end

    let(:walk_in_user) {
      instance_double(User, :walk_in? => true, :authenticated? => false)
    }

    let(:authenticated_user) {
      class User
        def user_data
          super
        end
      end
      instance_double(User, :walk_in? => false, :authenticated? => true, :user_data => 'this is the user_data')
    }

    let(:anonymous_user) {
      instance_double(User, :walk_in? => false, :authenticated? => false)
    }

    let(:successful_response) {
      Struct.new(:code).new(200)
    }

    # the following most just asserts that the code does not fail,
    # but it's at least better than no tests
    it 'sends feedback email for a walk-in user' do
      expect(HTTParty).to receive(:post).and_return(successful_response)
      SendIt.send_feedback_email(walk_in_user, {})
    end

    it 'sends feedback email for an authenticated user' do
      expect(HTTParty).to receive(:post).and_return(successful_response)
      SendIt.send_feedback_email(authenticated_user, {})
    end

    it 'sends feedback email for a anonymous user' do
      expect(HTTParty).to receive(:post).and_return(successful_response)
      SendIt.send_feedback_email(anonymous_user, {})
    end
  end
end
