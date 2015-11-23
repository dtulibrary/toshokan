# encoding: utf-8

Then(/^I should not see any pagination$/) do
  expect(page).to_not have_css('.pagination')
end

Then(/^I should see page links from (\d+) to (\d+)$/) do |from, to|
  (from.to_i..to.to_i).each{ |page_number|
    expect(page).to have_css('.pagination ul li a', :text => "#{page_number}")
  }
end

Then(/^the link to page (\d+) should appear as the current page$/) do |page_number|
  expect( find('.pagination ul li', :text => page_number)[:class] ).to include('active')
end

Then(/^the (next|previous) page link should be active$/) do |link_type|
  expect( find('.pagination ul li', :text => (link_type == 'next' ? 'Next »' : '« Previous'))[:class] ).to_not include('disabled')
end

Then(/^the (next|previous) page link should be inactive$/) do |link_type|
  expect( find('.pagination ul li', :text => (link_type == 'next' ? 'Next »' : '« Previous'))[:class] ).to include('disabled')
end

Then(/^I should see the (forward|backward) page gap$/) do |gap_type|
  expect( all('.pagination ul li')[gap_type == 'forward' ? -1 : -2].text).to eq'…'
end

Then(/^I should not see the (forward|backward) page gap$/) do |gap_type|
  expect( find('.pagination ul li')[gap_type == 'forward' ? -1 : 2].text).to eq'…'
end

Then(/^I should see both page gaps$/) do
  expect(all('.pagination ul li')[2].text).to eq '…'
  expect(all('.pagination ul li')[-1].text).to eq '…'
end

Then(/^I should not see any page gaps$/) do
  expect(page).to_not have_css('.pagination ul li a', :text => '...')
end

When(/^I go to page (\d+) of the result set$/) do |page_number|
  page.find('.pagination a', :text => page_number).click
end

When(/^I go to the (next|previous) page of the result set$/) do |link_type|
  click_link (link_type == 'next' ? 'Next »' : '« Previous'), :match => :first
end
