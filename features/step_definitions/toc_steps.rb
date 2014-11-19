Then /^I should see a journal with table of contents$/ do
  # page.should have_css '#document.blacklight-journal .toc'
  page.should have_css '#document .toc'
  page.should have_css '.toc .toc_issues'
  page.should have_css '.toc .toc_articles'
end

Then /^I should see at least (\d+) years of issues$/ do |n|
  expect(all('.toc_year').count).to be >= n.to_i
end

Then /^I should see the first issue as selected$/ do
  first_issue = find('.toc_issue', match: :first)
  first_issue.tag_name.should_not eq 'a'
end

Then /^I should see the second issue as selected$/ do
  first_issue = find('.toc_issue', match: :first)
  first_issue.tag_name.should eq 'a'
  second_issue = first_issue.find(:xpath, './../following-sibling::*/*', match: :first)
  second_issue.tag_name.should_not eq 'a'
end

Then /^I should see the list of articles in the issue$/ do
  find('.toc_articles').should have_css('.toc_article')
end
