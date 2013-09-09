Given /^I(?:'m| am) on the "can't find" form for "(.*?)"$/ do |genre|
  visit cant_find_path(:genre => genre.gsub(' ', '_'))
end

When /^I fill in the "(.*?)" section with the following values$/ do |section, ast|
  within ".#{section.gsub ' ', '-'}-section" do
    ast.rows_hash.each do |field, value|
      step %{I fill in "#{field}" with "#{value}"}  
    end
  end
end

Then /^I should(n't| not)? see the "can't find" form links$/ do |negate|
  step %{I should see the result page}
  step %{I should see "No results in DTU Findit"}
  step %{I should#{negate} see the "Contact librarian to order journal article" link}
  step %{I should#{negate} see the "Contact librarian to order conference article" link}
  step %{I should#{negate} see the "Contact librarian to order book" link}
end

Then /^I should(n't| not)? see the "can't find" help links$/ do |negate|
  step %{I should see the result page}
  step %{I should see "No results in DTU Findit"}
  step %{I should#{negate} see the "Journal article" link}
  step %{I should#{negate} see the "Conference article" link}
  step %{I should#{negate} see the "Book" link}
end

Then /^I should(n't| not)? see the "can't find" form for journal article$/ do |negate|
  if negate
    page.should_not have_css ".article-section"
  else
    step %{I should see the article form section}
    step %{I should see the journal form section}
    step %{I should see the notes form section}
  end
end

Then /^I should(n't| not)? see the "can't find" form for conference article$/ do |negate|
  if negate
    page.should_not have_css ".conference-section"
  else
    step %{I should see the article form section}
    step %{I should see the proceedings form section}
    step %{I should see the conference form section}
    step %{I should see the notes form section}
  end
end

Then /^I should(n't|not )? see the "can't find" form for book$/ do |negate|
  if negate
    page.should_not have_css ".book-section"
  else
    step %{I should see the book form section}
    step %{I should see the publisher form section}
    step %{I should see the notes form section}
  end
end

Then /^I should see the article form section$/ do
  within '.article-section' do
    step %{I should see "Article title"}
    step %{I should see "Author"}
    step %{I should see "DOI"}
  end
end

Then /^I should see the journal form section$/ do
  within '.journal-section' do
    step %{I should see "Journal title"}
    step %{I should see "ISSN"}
    step %{I should see "Vol."}
    step %{I should see "Iss."}
    step %{I should see "Year"}
    step %{I should see "Pages"}
  end
end

Then /^I should see the notes form section$/ do
  within '.notes-section' do
    step %{I should see "Notes"}
  end
end

Then /^I should see the email form section$/ do
  within '.email-section' do
    step %{I should see "Email"}
  end
end

Then /^I should see the physical location form section$/ do
  within '.physical-location-section' do
    step %{I should see "Physical location"}
  end
end

Then /^I should see the pickup location form section$/ do
  within '.pickup-location-section' do
    step %{I should see "Lyngby"}
    step %{I should see "Ballerup"}
  end
end

Then /^I should see the proceedings form section$/ do
  within '.proceedings-section' do
    step %{I should see "Proceedings/series title"}
    step %{I should see "ISSN/ISBN"}
    step %{I should see "Pages"}
  end
end

Then /^I should see the conference form section$/ do
  within '.conference-section' do
    step %{I should see "Conference title"}
    step %{I should see "Location"}
    step %{I should see "Year"}
    step %{I should see "No."}
  end
end

Then /^I should see the book form section$/ do
  within '.book-section' do
    step %{I should see "Book title"}
    step %{I should see "Author"}
    step %{I should see "Edition"}
    step %{I should see "DOI"}
    step %{I should see "ISBN"}
    step %{I should see "Year"}
  end
end

Then /^I should see the publisher form section$/ do
  within '.publisher-section' do
    step %{I should see "Publisher name"}
  end
end

Then /^I should see the "(.*?)" section with the following values$/ do |section, ast|
  within ".#{section.gsub ' ', '-'}-section" do
    ast.rows_hash.each do |field, value|
      step %{I should see "#{field}"}
      step %{I should see "#{value}"}
    end
  end
end

Then /^I should(n't| not)? see the can't find menu items$/ do |negate|
  within '#facets' do
    if negate
      should_not have_css '.cant-find-items' 
    else
      step %{I should see "Can't find what you're looking for?"}
      step %{I should see "Journal article"}
      step %{I should see "Conference article"}
      step %{I should see "Book"}
    end
  end
end
