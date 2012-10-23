Feature: Application mode

  The application can run in various modes, differentiating the behaviour
  of anonymous users and users that are logged in across the different modes.

  Scenario: The application runs in DTU mode
    Given the application runs in "dtu" mode
      # XXX: Omniauth needs to mock cas response which is why
      # the logged in stuff is here at the moment.
      And I'm logged in
     When I go to the root page
     Then I should see the "Logout" link
      But I should not see the "Login" link

#  Scenario: The application runs in DTU kiosk mode
#    Given the application runs in "dtu_kiosk" mode
#     When I go to the root page
#     Then I should see the search page
#      But I should not see the "Login" link
#      And I should not see the "Logout" link

#  Scenario: The application runs in I4I mode
#    Given the application runs in "i4i" mode
#     When I go to the root page
#     Then I should see the search page
#      And I should see the "Login" link

