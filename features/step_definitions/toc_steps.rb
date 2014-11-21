Then /^I should see a journal with table of contents$/ do
  # expect(page).to have_css '#document.blacklight-journal .toc'
  expect(page).to have_css '#document .toc'
  expect(page).to have_css '.toc .toc_issues'
  expect(page).to have_css '.toc .toc_articles'
end

Then /^I should see at least (\d+) years of issues$/ do |n|
  expect(all('.toc_year').count).to be >= n.to_i
end

Then /^I should see the first issue as selected$/ do
  first_issue = find('.toc_issue', match: :first)
  expect( first_issue.tag_name).to_not eq 'a'
end

Then /^I should see the second issue as selected$/ do
  first_issue = find('.toc_issue', match: :first)
  expect( first_issue.tag_name ).to eq 'a'
  second_issue = first_issue.find(:xpath, './../following-sibling::*/*', match: :first)
  expect( second_issue.tag_name ).to_not eq 'a'
end

Then /^I should see the list of articles in the issue$/ do
  expect( find('.toc_articles') ).to have_css('.toc_article')
end
