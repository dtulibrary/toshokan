# encoding: utf-8

Rails.application.config.to_prepare do
  Riyosha.configure do |config|
    config.url      = Toshokan::Application.config.auth[:api_url]
  end

  if Rails.application.config.auth[:stub]
    Riyosha.config.test_mode = true
    Riyosha.config.add_mock('1234', {
        'id'         => '1234',
        'email'      => 'someone@example.com',
        'dtu'        => {
          'firstname' => 'Firstname',
          'lastname'  => 'Lastname',
          'user_type' => 'dtu_empl',
          'org_units' => ['58']
        },
        'address' => {
          'line1'    => 'Address line 1',
          'line2'    => 'Address line 2',
          'line3'    => 'Address line 3',
          'line4'    => 'Address line 4',
          'line5'    => 'Address line 5',
          'line6'    => 'Address line 6',
          'zipcode'  => 'ZIP',
          'cityname' => 'City',
          'country'  => 'Country'
        }
      }
    )
  end
end
