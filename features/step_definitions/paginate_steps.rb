# encoding: utf-8

Then /^I should not see any pagination$/ do
  page.has_css?('.pagination').should be_falsey
end

Then /^I should see page links from (\d+) to (\d+)$/ do |from, to|
  (from.to_i..to.to_i).each{ |page_number|
    page.has_css?('.pagination ul li a', :text => "#{page_number}").should be_truthy
  }
end
Then /^the (next|previous) page link should be active$/ do |link_type|
  find('.pagination ul li', :text => (link_type == 'next' ? 'Next »' : '« Previous'))[:class].should_not include('disabled')
end

Then /^the (next|previous) page link should be inactive$/ do |link_type|
  find('.pagination ul li', :text => (link_type == 'next' ? 'Next »' : '« Previous'))[:class].should include('disabled')
end

Then /^I should see the (forward|backward) page gap$/ do |gap_type|
  #debugger
  all('.pagination ul li a')[gap_type == 'forward' ? -1 : -2].text.should =='…'
end

Then /^I should not see the (forward|backward) page gap$/ do |gap_type|
  find('.pagination ul li a')[gap_type == 'forward' ? -1 : 2].text.should_not == '…'
end

Then /^I should see both page gaps$/ do
  all('.pagination ul li a')[2].text.should == '…'
  all('.pagination ul li a')[-1].text.should == '…'
end

Then /^I should not see any page gaps$/ do
  page.should_not have_css('.pagination ul li a', :text => '...')
end

When /^I go to page (\d+) of the result set$/ do |page_number|
  page.find('.pagination a', :text => page_number).click
end

When /^I go to the (next|previous) page of the result set$/ do |link_type|
  click_link (link_type == 'next' ? 'Next »' : '« Previous')
end
