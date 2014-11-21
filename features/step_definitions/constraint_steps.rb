Then /^I should(?:n't| not) see any links to remove the constraint$/ do
  within '#appliedParams .constraint' do
    expect(page).to_not have_css 'a.remove-filter'
  end
end

Then /^the "(.*?)" facet should be constrained to "(.*?)"$/ do |name, value|
  within '#appliedParams .constraint' do
    expect(page).to have_css('.filterName', :text => "#{name}")
    expect(page).to have_css('.filterValue', :text => value)
  end
end

Then /^I should see a limit constraint for "(.*?)"$/ do |name|
  within '#appliedParams' do
    expect(page).to have_css('.filterName', :text => "#{name}")
  end
end

Then /^I should not see a limit constraint for "(.*?)"$/ do |name|
  within '#appliedParams' do
    expect(page).to_not have_css('.filterName', :text => "#{name}")
  end
end

Then /^I should see a limit constraint that begins with "(.*?)"$/ do |value|
  within '#appliedParams' do
    expect(page).to have_css('.filterValue', :text => /#{value}.*/)
  end
end
