Then(/^I should(n't| not)? see the altmetric badge for doi "(.*?)"$/) do |negate, doi|
  expect( page ).send( (negate ? :to_not : :to), have_xpath("//div[@class=\"altmetric-embed\" and @data-doi=\"#{doi}\"]") )
end
