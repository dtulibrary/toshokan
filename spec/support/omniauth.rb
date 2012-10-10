OmniAuth.config.test_mode = true
OmniAuth.config.add_mock(:cas, {
  :uid => 'abcd',
  :info => { :name => 'Firstname Lastname' },  
  :extra => {
    :norEduPerson => [{
      :norEduPersonLIN => '98765'
    }]
  }
})

def login(user = User.create!(provider: "cas", identifier: rand(99999).to_s))
  session[:user_id] = user.id
  user
end