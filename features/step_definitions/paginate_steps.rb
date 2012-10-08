Then /^I should not see any pagination$/ do
  page.has_css?('.pagination-container').should be_false
end

Then /^I should see (\d+) page links$/ do |number_of_pages|
  page_gaps = page.all('.page_links .page.gap').size

  # Double up on number_of_pages since there is a page selector above 
  # and below document list.
  (page.all('.page_links .page').size - page_gaps).should == 2 * number_of_pages.to_i
end

Then /^I should((?:n't| not))? see the page gap$/ do |negate|
  page.has_css?('.page.gap').should (negate ? be_false : be_true)
end

Then /^I should((?:n't| not))? see the (next|previous) page link$/ do |negate, link_type|
  # Next and previous links have CSS classes 'next_page' and 'prev_page'.
  # When they're disabled, they also get CSS class 'disabled'.
  page.has_css?(".#{link_type == 'next' ? 'next' : 'prev'}_page#{negate ? '.disabled' : ''}").should be_true
end

Then /^I should((?:n't| not))? see the (forward|backward) page gap$/ do |negate, gap_type|
  gap_selector = '.page.gap:' + (gap_type == 'forward' ? 'last-child' : 'first-child')
  page.has_css?(gap_selector).should (negate ? be_false : be_true)
end

Then /^I should(?:n't| not) see any page gaps$/ do 
  page.has_css?('.page.gap').should be_false
end

Then /^I should see both page gaps$/ do
  page.all('.page.gap:first-child, .page.gap:last-child').size.should == 4
end

When /^I go to page (\d+) of the result set$/ do |page_number|
  page.find('.page a', :text => page_number).click
end

When /^I go to the (next|previous) page of the result set$/ do |link_type|
  page.find(".#{link_type == 'next' ? 'next' : 'prev'}_page a").click
end
