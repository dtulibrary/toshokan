Given /^I bookmark the( first)? document$/ do |first|
  scope = first ? find('.documentFunctions') : page
  scope.click_on 'Bookmark'
end

When /^I bookmark the document with title "(.*?)"$/ do |title|
  steps %{
    And I go to the record page for "#{title}"
    And I bookmark the document
  }
end

When /^I unbookmark the( first)? document$/ do |first|
  scope = first ? find('.documentFunctions') : page
  scope.find('.bookmark').click_on 'Remove'
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
  visit(advanced_path)

  fill_in('Title', :with => query)
  click_button('advanced_search')

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
  within(".tags_as_labels .tag", :text => tag_name) do
    click_on 'Remove'
  end
end

Given /^I remove the tag "(.*?)" from the document with title "(.*?)"$/ do |tag_name, query|
  visit(advanced_path)

  fill_in('Title', :with => query)
  click_button('advanced_search')

  within(".document .documentFunctions .tag", :text => tag_name) do
    click_link 'Remove'
  end
end

Given /^I filter by tag "(.*?)"$/ do |tag_name|
  visit(root_path(:simple_search => true))

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
    click_link 'Edit'
  end
  fill_in('tag_name', :with => new_tag_name)
  click_button 'Save'
end

Given /^I delete tag "(.*?)"$/ do |tag_name|
  visit manage_tags_path
  within(:xpath, "//tr[td/span/text()='#{tag_name}']") do
    click_link 'Delete'
  end
end

Then /^the( first)? document should be bookmarked$/ do |first|
  scope = first ? find('.documentFunctions') : page
  scope.should have_css('.tag_control .bookmark')
end

Then /^the( first)? document should not be bookmarked$/ do |first|
  scope = first ? find('.documentFunctions') : page
  scope.should_not have_css('.tag_control .bookmark')
end

Then /^the(?: first)? document should have tags$/ do
  page.should have_css('.tags_dropdown .btn-danger', :text => 'Tags')
end

Then /^the(?: first)? document should not have tags$/ do
  page.should have_css('.tags_dropdown .btn', :text => 'Tags')
  page.should_not have_css('.tags_dropdown .btn-danger'), :text => 'Tags'
end

Then /^the document should be tagged with "(.*?)"$/ do |tag_name|
  page.should have_css('.tags_as_labels .tag', :text => tag_name)
end

Then /^the document should not be tagged with "(.*?)"$/ do |tag_name|
  page.should_not have_css('.tags_as_labels .tag', :text => tag_name)
end
