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
  step %{I should see "0 hits"}
  step %{I should#{negate} see the "Journal article" link}
  step %{I should#{negate} see the "Conference article" link}
  step %{I should#{negate} see the "Book" link}
end

Then /^I should see the "can't find" form for journal article$/ do 
  step %{I should see the article form section}
  step %{I should see the journal form section}
  step %{I should see the notes form section}
  step %{I should see the email form section}
  step %{I should see the physical location form section}
end

Then /^I should see the "can't find" form for conference article$/ do
  step %{I should see the article form section}
  step %{I should see the proceedings form section}
  step %{I should see the conference form section}
  step %{I should see the notes form section}
  step %{I should see the email form section}
  step %{I should see the physical location form section}
end

Then /^I should see the "can't find" form for book$/ do
  step %{I should see the book form section}
  step %{I should see the publisher form section}
  step %{I should see the notes form section}
  step %{I should see the email form section}
  step %{I should see the physical location form section}
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
