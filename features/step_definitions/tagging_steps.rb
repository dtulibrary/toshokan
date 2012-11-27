Given /^I add a tag "(.*?)" to the(?: first)? document$/ do |tag_name|
  click_link 'Add tag'
  fill_in 'Tag', with: tag_name
  click_button 'Add tag'
end

Given /^I add a tag "(.*?)" to the document with title "(.*?)"$/ do |tag_name, query|
  visit(root_path)

  fill_in('q', :with => query)
  select 'Title', :from => 'in'
  click_button('search')

  click_link 'Add tag'
  fill_in 'Tag', with: tag_name
  click_button 'Add tag'
end

Given /^I remove the tag "(.*?)" from the(?: first)? document$/ do |tag_name|
  within(".document .documentFunctions .tag", :text => tag_name) do
    click_link 'Remove'
  end
end

Given /^I remove the tag "(.*?)" from the document with title "(.*?)"$/ do |tag_name, query|
  visit(root_path)

  fill_in('q', :with => query)
  select 'Title', :from => 'in'
  click_button('search')

  within(".document .documentFunctions .tag", :text => tag_name) do
    click_button 'x'
  end
end

Given /^I filter by tag "(.*?)"$/ do |tag_name|
  click_link tag_name
end

Given /^I list my tags$/ do
  visit tags_path
end

Given /^I rename tag "(.*?)" to "(.*?)"$/ do |tag_name, new_tag_name|
  visit tags_path
  within(:xpath, "//tr[td/span/text()='#{tag_name}']") do
    click_link 'Edit'
  end
  fill_in('tag_name', :with => new_tag_name)
  click_button 'Save'
end

Given /^I delete tag "(.*?)"$/ do |tag_name|
  visit tags_path
  within(:xpath, "//tr[td/span/text()='#{tag_name}']") do
    click_link 'Delete'
  end
end