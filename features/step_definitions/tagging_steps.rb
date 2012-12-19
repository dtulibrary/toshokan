Given /^I add a tag "(.*?)" to the first document$/ do |tag_name|
  click_on 'Tags'
  fill_in 'tag_name', with: tag_name
  click_button 'Add'
end

Given /^I add a tag "(.*?)" to the document$/ do |tag_name|
  click_on 'Tags'
  fill_in 'tag_name', with: tag_name
  click_button 'Add'
end

Given /^I add a tag "(.*?)" to the document with title "(.*?)"$/ do |tag_name, query|
  visit(root_path)

  fill_in('q', :with => query)
  select 'Title', :from => 'in'
  click_button('search')

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
  visit(root_path)

  fill_in('q', :with => query)
  select 'Title', :from => 'in'
  click_button('search')

  within(".document .documentFunctions .tag", :text => tag_name) do
    click_link 'Remove'
  end
end

Given /^I filter by tag "(.*?)"$/ do |tag_name|
  find("#facets .twiddle", :text => 'Bookmarks').click
  find('#facets a', :text => tag_name).should be_visible

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

Then /^I should see "(.*?)" on the document$/ do |tag_name|
  find('.tags_as_labels .tag', :text => tag_name).should be_visible
end

Then /^I should not see "(.*?)" on the document$/ do |tag_name|
  page.should_not have_css('.tags_as_labels .tag', :text => tag_name)
end

Then /^I should see "(.*?)" on the first document$/ do |tag_name|
  find('.tags_as_labels .tag', :text => tag_name).should be_visible
end

Then /^I should not see "(.*?)" on the first ocument$/ do |tag_name|
  page.should_not have_css('.tags_as_labels .tag', :text => tag_name)
end
