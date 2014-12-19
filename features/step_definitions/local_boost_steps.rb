# Confirms that there is a search result with/without the local boost css and indicator image (logo)
# Fails if there is no document with the specified title.
Then(/^I should see "(.*?)" with(out)? local boost$/) do |title,negate|
  # Expect the .document div corresponding to the specified title to have (or not have) the .homegrown class
  expect( page ).send( (negate ? :to_not : :to), have_css(".document.homegrown .documentHeader .index_title a", text:title) )
  # This 'within' statement should fail if there is no document with the specified title.
  within(:xpath, xpath_for_document(title)) do
    # confirms that the homegrown-indicator does/doesn't appear for this document
    expect( page ).send( (negate ? :to_not : :to), have_css("img.homegrown-indicator") )
  end
end

# XPath query for finding the .document div that corresponds to the given title
# (finds the .document div that's showing the given title as its index_title link)
def xpath_for_document(title)
  "//div[contains(@class,'document') and div/h5[contains(@class,'index_title')]/a[text()='#{title}']]"
end