Then(/^I should see the altmetric badge for doi "(.*?)"$/) do |doi|
  expect( page ).to have_xpath("//div[@class=\"altmetric-embed\" and @data-doi=\"#{doi}\"]")
end