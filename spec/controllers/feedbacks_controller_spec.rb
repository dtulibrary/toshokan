require 'rails_helper'

describe FeedbacksController do
  let(:name) {
    'firstname lastname'
  }
  let(:email) {
    'me@example.com'
  }
  let(:message) {
    'My message'
  }
  describe '#new' do
    it 'assigns name, email and message' do
      get :new, :name => name, :email => email, :message => message
      expect(assigns(:name)).to eq(name)
      expect(assigns(:email)).to eq(email)
      expect(assigns(:message)).to eq(message)
    end

    it 'renders the form' do
      get :new
      expect(response).to render_template 'new', :partial => 'form'
    end

    it 'renders the form in a modal on ajax requests' do
      xhr :get, :new
      expect(response).to render_template 'new_modal', :partial => 'form'
    end
  end

  describe '#create' do
    it 'invokes SendIt to a feedback email' do
      expect(SendIt).to receive(:send_feedback_email).with(instance_of(User),
                                                           hash_including(:from => "#{name} <#{email}>",
                                                                          :message => message))

      xhr :post, :create, :message => message, :email => email, :name => name
      expect(response).to render_template 'complete'
    end

    it 'renders an error when message param is missing' do
      xhr :post, :create, :message => '', :email => email, :name => name
      expect(response).to render_template 'error'
    end

    it 'renders an error when email param is missing' do
      xhr :post, :create, :message => message, :email => ' ', :name => name
      expect(response).to render_template 'error'
    end
  end
end
