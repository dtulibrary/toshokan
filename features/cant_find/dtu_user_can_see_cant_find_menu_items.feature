Feature: DTU user can see "can't find" menu items

When searching, A DTU user should be presented with
a section in the left menu (facets) where he can
click to get to the individual "can't find" forms.
Non-DTU users should not see this section.

#Scenario Outline:
#  Given <login_condition>
#    And I'm on the search page
#   When I search for "water"
#   Then I <should_form> see the can't find menu items
#
#Examples:
#  | login_condition                 | should_form |
#  | I haven't logged in             | shouldn't   |
#  | I'm logged in as a DTU employee | should      |
#  | I'm logged in as a DTU student  | should      |
#  | I'm logged in as a public user  | shouldn't   |
#  | I'm a walk-in user              | shouldn't   |
