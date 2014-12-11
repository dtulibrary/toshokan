When(/^I should(n't| not)? see (?:a|any) DTU ORBIT backlinks?$/) do |negate|
  expect(page).send( (negate ? :to_not : :to), have_css('.dtu-orbit-backlink') )
end
