require 'rails_helper'

describe 'feedbacks/new_modal' do
  let(:name) {
    'firstname lastname'
  }
  let(:email) {
    'me@example.com'
  }
  let(:message) {
    'My message'
  }

  it 'populates the name, email, and message field' do
    assign :name, name
    assign :email, email
    assign :message, message
    render
    expect(rendered).to have_field('name', :with => name)
    expect(rendered).to have_field('email', :with => email)
    expect(rendered).to have_field('message', :with => message, :type => 'textarea')
  end
end
