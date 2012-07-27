Given /^I add a tag "(.*?)" to the first document$/ do |tag_name|
  click_link 'Add tag'
  fill_in 'Tag', with: tag_name
  click_button 'Add tag'
end

Given /^I browse the tag "(.*?)"$/ do |tag_name|
  visit tags_path
  click_link tag_name
end