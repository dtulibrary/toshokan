Given /^I bookmark the( first)? document$/ do |first|
  scope = first ? find('.documentFunctions', :match=>:first) : page
  scope.click_on 'Bookmark'
end

When /^I bookmark the document with title "(.*?)"$/ do |title|
  step "I go to the record page for \"#{title}\""
  step "I bookmark the document"
end

When /^I unbookmark the( first)? document$/ do |first|
  scope = first ? find('.documentFunctions', :match=>:first) : page
  scope.click_on 'Remove bookmark and tags'
end

Given /^I add a tag "(.*?)" to the first document$/ do |tag_name|
  click_on 'Tags'
  within('.new_tag') do
    fill_in 'tag_name', with: tag_name
    click_button 'Add'
  end
end

Given /^I add a tag "(.*?)" to the document$/ do |tag_name|
  click_on 'Tags'
  within('.new_tag') do
    fill_in 'tag_name', with: tag_name
    click_button 'Add'
  end
end

Given /^I add a tag "(.*?)" to the document with title "(.*?)"$/ do |tag_name, query|
  step "I search for \"#{query}\" in the title"

  click_on 'Tags'
  fill_in 'tag_name', with: tag_name
  click_button 'Add'
end

Given /^I remove the tag "(.*?)" from the first document$/ do |tag_name|
  click_on 'Tags'
  within(".existing_tags .tag", :text => tag_name) do
    click_on 'Remove'
  end
end

Given /^I remove the tag "(.*?)" from the document$/ do |tag_name|
  within(".tag", :text => tag_name, :match => :first) do
    click_on 'Remove'
  end
end

Given /^I remove the tag "(.*?)" from the document with title "(.*?)"$/ do |tag_name, query|
  step "I search for \"#{query}\" in the title"

  within(".document .documentFunctions .tag", :text => tag_name) do
    click_link 'Remove'
  end
end

Given /^I filter by tag "(.*?)"$/ do |tag_name|
  visit(root_path)

  if !find('#facets a', :text => tag_name).visible?
    find("#facets .twiddle", :text => 'Bookmarks').click
  end

  within('.facet_limit .tag_list') do
    click_link tag_name
  end
end

Given /^I list my tags$/ do
  visit manage_tags_path
end

Given /^I rename tag "(.*?)" to "(.*?)"$/ do |tag_name, new_tag_name|
  visit manage_tags_path
  within(:xpath, "//tr[td/span/text()='#{tag_name}']") do
    find(:xpath, "//a[@title='Edit']").click
  end
  fill_in('tag_name', :with => new_tag_name)
  click_button 'Save'
end

Given /^I delete tag "(.*?)"$/ do |tag_name|
  visit manage_tags_path
  within(:xpath, "//tr[td/span/text()='#{tag_name}']") do
    find(:xpath, "//a[@title='Delete']").click
  end
end

Then /^the( first)? document should be bookmarked$/ do |first|
  scope = first ? find('.documentFunctions', :match => :first) : page
  scope.should have_css('.tag_control .icon-star')
end

Then /^the( first)? document should not be bookmarked$/ do |first|
  scope = first ? find('.documentFunctions', :match=>:first) : page
  scope.should_not have_css('.tag_control .icon-star')
end

Then /^the( first)? document should have tags$/ do |first|
  scope = first ? find('.documentFunctions') : page
  scope.should have_css('.tags_dropdown .has-tags')
end

Then /^the( first)? document should not have tags$/ do |first|
  scope = first ? find('.documentFunctions', :match=>:first) : page
  scope.should have_css('.tags_dropdown .no-tags')
end

Then /^the( first)? document should be tagged with "(.*?)"$/ do |first, tag_name|
  scope = first ? find('.documentFunctions') : page
  scope.should have_css('.tags-as-labels .tags .tag', :text => tag_name)
end

Then /^the( first)? document should not be tagged with "(.*?)"$/ do |first, tag_name|
  scope = first ? find('.documentFunctions') : page
  scope.should_not have_css('.tags-as-labels .tags .tag', :text => tag_name)
end

Then /^I should see a tag constraint with name "(.*?)" and value "(.*?)"$/ do |name, value|
  within('.tag-constraint.constraint') do
    find('.filterName').should have_content name
    find('.filterValue').should have_content value
  end
end

Then /^I should see a clickable tag facet with name "(.*?)"$/ do |tag_name|
  find('.facet_limit .tag_list').should have_css('a', :text => tag_name)
end

Then /^I should see an inactive tag facet with name "(.*?)"$/ do |tag_name|
  find('.facet_limit .tag_list').should_not have_css('a', :text => tag_name)
end
