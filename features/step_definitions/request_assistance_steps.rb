Given(/^I(?:'m| am) on the "request assistance" form$/) do
  @form  = 'request assistance'
  visit new_assistance_request_path
end

Given(/^I(?:'m| am) on the "request assistance" form for "(.*?)"$/) do |genre|
  @genre = genre
  @form  = 'request assistance'
  visit new_assistance_request_path(:genre => genre.gsub(' ', '_'))
end

{
  'journal article'    => ['article', 'journal', 'electronic delivery', 'physical delivery', 'automatic cancellation', 'notes', 'submit'],
  'conference article' => ['article', 'conference', 'electronic delivery', 'physical delivery', 'automatic cancellation', 'notes', 'submit'],
  'book'               => ['book', 'electronic delivery', 'physical delivery', 'automatic cancellation', 'notes', 'submit'],
  'thesis'             => ['thesis', 'electronic delivery', 'physical delivery', 'automatic cancellation', 'notes', 'submit'],
  'report'             => ['report', 'host', 'electronic delivery', 'physical delivery', 'automatic cancellation', 'notes', 'submit'],
  'standard'           => ['standard', 'electronic delivery', 'physical delivery', 'automatic cancellation', 'notes', 'submit'],
  'patent'             => ['patent', 'submit'],
  'other'              => ['other', 'host', 'electronic delivery', 'physical delivery', 'automatic cancellation', 'notes', 'submit']
}.each do |genre, sections|
  Given %r{^I(?:'ve| have) submitted a valid "request assistance" form for "#{genre}"$} do
    step %{I fill out a valid "request assistance" form for "#{genre}"}
    step %{I click "Send request"}
    step %{I decline any resolver results}
  end

  Given %r{^I(?:'ve| have) created a request for assistance for an? "#{genre}"$} do
    step %{I've submitted a valid "request assistance" form for "#{genre}"}
    step %{I click "Confirm request"}
  end

  Given %r{^I(?:'ve| have)? fill(?:ed)? out a valid "request assistance" form for "#{genre}"$} do
    step %{I'm on the "request assistance" form for "#{genre}"}
    sections.each do |section|
      step %{I fill in the "#{section}" form section with valid data}
    end
  end

  Then %r{^I should see the "request assistance" confirmation page for "#{genre}"$} do
    step %{I should see "Please confirm your assistance request"}
    sections.each do |section|
      step %{I should see the "#{section}" section with the submitted data}
    end
  end

  Then %r{^I should(n't| not)? see the "request assistance" form for "#{genre}"$} do |negate|
    check_form_correctness sections, negate
    step %{I should#{negate} see the "Send request" #{negate ? 'or' : 'and'} "Clear" buttons}
  end
end

When(/^I go to the "request assistance" form for "(.*?)"$/) do |genre|
  step %{I'm on the "request assistance" form for "#{genre}"}
end

When(/^I go to the "request assistance" form$/) do
  step %{I'm on the "request assistance" form}
end

# Examples:
#   I fill in the "article" form sections with valid data
#   I fill in the "article", "journal" form sections with valid data
#   I fill in the "article" and "journal" form sections with valid data
#   I fill in the "article", "journal" and "notes" form sections with valid data
When(/^I fill in the (".*") form sections with valid data$/) do |sections|
  sections.scan(/"(.*?)"/) do |section, _|
    step %{I fill in the "#{section}" form section with valid data}
  end
end

When %r{^I fill in "(.*?)" in the "(.*?)" form section with "(.*)"$} do |field, section, value|
  within locator_for_section(section) do
    step %{I fill in "#{field}" with "#{value}"}
    submitted_data[section] ||= {}
    submitted_data[section][field] = value
  end
end

When(/^I fill in the "request assistance" form with valid data$/) do
  step %{I fill in the #{form_sections[@genre].collect {|s| "\"#{s}\""}.join ','} form sections with valid data}
end

When %r{^I submit the "request assistance" form$} do
  step %{I click "Send request"}
end

When %r{^I confirm the "request assistance" form submission$} do
  step %{I click "Confirm request"}
end

When(/^I select pickup location "(.*?)"$/) do |location|
  within locator_for_section('pickup-location') do
    choose(location)
    submitted_data['pickup_location'] = value
  end
end

Then(/^I should see the (".*") form sections with the submitted$/) do |sections|
  sections.scan(/"(.*?)"/) do |section, _|
    step %{I should see the "#{section}" form section with the submitted data}
  end
end

Then(/^I should see the (".*") sections with the submitted data$/) do |sections|
  sections.scan(/"(.*?)"/) do |section, _|
    step %{I should see the "#{section}" section with the submitted data}
  end
end

Then %r{^I should see the "request assistance" confirmation page$} do
  if @genre
    step %{I should see the "request assistance" confirmation page for "#{@genre}"}
  else
    step %{I should see the "Please confirm your request"}
  end
end

['article', 'journal', 'host', 'notes', 'conference', 'book', 'publisher', 'thesis', 'report', 'standard', 'patent', 'other'].each do |section|
  When %r{^I fill in the "#{section}" form section with valid data$} do
    submitted_data[section] = valid_section_data[section]
    fill_in_section section, submitted_data[section]
  end

  Then %r{^I should see the "#{section}" form section with the submitted data$} do
    within locator_for_section(section) do
      submitted_data[section].each do |field, value|
        expect(find_field(field).value).to eq value
      end
    end
  end

  Then %r{^I should see the "#{section}" section with the submitted data$} do
    within locator_for_section(section) do
      submitted_data[section].each do |field, value|
        step %{I should see "#{field}"}
        step %{I should see "#{value}"}
      end
    end
  end
end

Then %r{^I should(n't| not) see a "request assistance" form$} do |negate|
  expect(page).to_not have_css('.request-assistance-form')
end

When(/^I fill in the "automatic cancellation" form section with valid data$/) do
  step %{I select automatic cancellation "3 months"}
end

When %r{^I decline (?:any|the) resolver results?$} do
  begin
    find_button('No, please send my request').click
  rescue Capybara::ElementNotFound
  end 
end

Then %r{^I should see the "electronic delivery" section with the submitted data$} do
  within locator_for_section('electronic-delivery') do
    step %{I should see "#{@current_user.email}"}
  end
end

When %r{^I fill in the "electronic delivery" form section with valid data$} do
  submitted_data['electronic delivery'] = @current_user.email
end

When %r{^I fill in the "submit" form section with valid data$} do
end

Then %r{^I should see the "submit" section with the submitted data$} do
  within locator_for_section('submit') do
    step %{I should see "Confirm request"}
  end
end

Then %r{^I should see the "physical delivery" (?:form )?section with the submitted data$} do
  within locator_for_section('physical-delivery') do
    step %{I should see "#{submitted_data['physical_delivery']}"}
  end
end

When %r{^I fill in the "physical delivery" form section with valid data$} do
  step %{I select physical delivery "Pick-up: DTU Library Lyngby"}    
end

Then %r{^I should see physical delivery to my DTU address$} do
  within locator_for_section('physical delivery') do
    @current_user.user_data['address'].reject {|k,v| v.blank? || k == 'country'}.each do |k,v|
      step %{I should see "#{v}"}
    end
  end
end

Given %r{^I(?:'ve| have) selected (.+) "(.*?)"$} do |section, option|
  step %{I select #{section} "#{option}"}
end

When %r{^I select (.+) "(.*?)"$} do |section, option|
  within locator_for_section(section) do
    choose(option)
    submitted_data[section] = option
  end
end

Then(/^I should see the "automatic cancellation" section with the submitted data$/) do
  within locator_for_section('automatic-cancellation') do
    step %{I should see "Last date of interest"}
    step %{I should see "#{submitted_data['auto_cancel']}"}
  end
end

Then(/^I should(n't| not)? see the "request assistance" form links$/) do |negate|
  ['Journal article', 'Conference article', 'Book', 'Thesis', 'Report', 'Standard', 'Patent'].each do |link|
    step %{I should#{negate} see the "#{link}" link}
  end
end

# Examples:
#   I should see the "Confirm" buttons
#   I should see the "Back" and "Confirm" buttons
#   I should see the "Back", "New" and "Confirm" buttons
Then(/^I should(n't| not)? see the (".*") buttons$/) do |negate, buttons|
  buttons.scan(/"(.*?)"/) do |button,_|
    step %{I should#{negate} see the "#{button}" button}
  end
end

Then(/^I should(n't| not)? see the "(.*?)" button$/) do |negate, button|
  expect(page).send(negate ? :to_not : :to, have_button(button))
end

Then(/^I should(?:n't| not) see the "(.*?)" section$/) do |section|
  expect(page).to_not have_sections([section])
end

Then(/^I should see the "(article|journal|host|notes|conference|book|publisher|thesis|report|standard|patent|other)" section$/) do |section|
  within locator_for_section(section) do
    section_fields[section].each do |field_label|
      step %{I should see "#{field_label}"}
    end
  end
end

Then(/^I should(n't| not)? see the "electronic delivery" section$/) do |negate|
  within '.electronic-delivery-section' do
    step %{I should#{negate} see "Email"}
  end
end

Then %r{^I should not see the "physical delivery" section$} do
  expect(page).to_not have_css('.physical-delivery-section')
end

Then %r{^I should see the "physical delivery" section$} do
  within locator_for_section('physical-delivery') do
    step %{I should see "Physical Delivery"}
    step %{I should see the Lyngby pick-up option}
    step %{I should see the Ballerup pick-up option}
  end
end

Then %r{^I should(n't| not)? see the deliver by internal mail option in the "physical delivery" section$} do |negate|
  begin
    within '.physical-delivery-section' do
      step %{I should#{negate} see "Send by DTU Internal Mail"}
      @current_user.user_data['address'].reject {|k,v| v.blank? || k == 'country'}.each do |k,v|
        step %{I should#{negate} see "#{v}"}
      end
    end
  rescue Capybara::ElementNotFound => e
    raise e unless negate
  end
end

Then(/^I should(n't| not)? see the "automatic cancellation" section$/) do |negate|
  within '.automatic-cancellation-section' do
    ['6 months', '3 months', '1 month'].each do |text|
      step %{I should#{negate} see "#{text}"}
    end
  end
end

Then(/^I should see the proper required fields in the "(.*?)" section$/) do |section|
  (required_section_fields[section] || []).each do |required_field|
    within locator_for_section(section) do
      # The following is really ugly but neither of
      # expect( find_field(required_field) ).to have_css('.required')
      # expect( (find_field(required_field)['class'] || '').split ).to include?('required')
      # worked for me so this is the current working solution
      expect( (find_field(required_field)['class'] || '').split.any? {|c| c == 'required'} ).to be_truthy
    end
  end
end

Then(/^I should see the proper optional fields in the "(.*?)" section$/) do |section|
  (optional_section_fields[section] || []).each do |optional_field|
    within locator_for_section(section) do
      # See comment from step for required fields
      expect( (find_field(optional_field)['class'] || '').split.any? {|c| c == 'required'}).to be_falsey
    end
  end
end

Then(/^I should see errors in the (".*") fields in the "(.*?)" form section$/) do |fields, section|
  fields.scan(/"(.*?)"/) do |field, _|
    step %{I should see an error in the "#{field}" field in the "#{section}" form section}
  end
end

Then(/^I should see an error in the "(.*?)" field in the "(.*?)" form section$/) do |field, section|
  within locator_for_section(section) do
    expect( (find_field(field)['class'] || '').split.any? {|c| c == 'error'}).to be_truthy
  end
end

Then(/^I should see the submitted data$/) do
  submitted_data.each do |section, fields|
    if fields.is_a? Hash
      fields.each do |field, value|
        step %{I should see "#{field}"}
        step %{I should see "#{value}"}
      end
    else
      step %{I should see "#{fields}"}
    end
  end
end

Then %r{^I should(n't| not)? see a link to the "request assistance" form for "(.*?)"$} do |negate, genre|
  within '.cant-find-links' do
    step %{I should#{negate} see the "#{form_link_titles[genre]}" link}
  end
end

Then %r{^I should(n't| not)? see a link to the "request assistance" form for "(.*?)" in the left menu$} do |negate, genre|
  within '#sidebar .cant-find-links' do
    step %{I should#{negate} see the "#{form_link_titles[genre]}" link}
  end
end

Then %r{^I should(?:n't| not) see any links to the "request assistance" forms in the left menu$} do
  expect(page).to_not have_css('#sidebar .cant-find-links')
end

Then %r{^I should(n't| not) see any links to the "request assistance" forms$} do |negate_form|
  expect(page).to_not have_css('.cant-find-links')
end

def check_form_correctness sections, negate = false
  if negate
    expect(page).to_not have_sections(sections)
  else
    expect(page).to have_sections(sections)
    sections.each do |section|
      step %{I should see the proper required fields in the "#{section}" section}
      step %{I should see the proper optional fields in the "#{section}" section}
    end
  end
end

def locator_for_section section
  ".#{section.downcase.gsub ' ', '-'}-section"
end

def submitted_data
  @submitted_data ||= {}
end

def submitted_data= value
  @submitted_data = value
end

def fill_in_section section, fields
  within locator_for_section(section) do
    fields.each do |field, value|
      if page.has_select?(field)
        page.select(value, :from => field)
      else
        step %{I fill in "#{field}" with "#{value}"}
      end
    end
  end
end

def form_link_titles
  {
    'journal article'    => 'Journal article',
    'conference article' => 'Conference article',
    'book'               => 'Book',
    'thesis'             => 'Thesis',
    'report'             => 'Report',
    'standard'           => 'Standard',
    'patent'             => 'Patent',
    'other'              => 'Other'
  }
end

def form_sections
  {
    'journal article'    => ['article', 'journal', 'notes', 'automatic cancellation'],
    'conference article' => ['article', 'conference', 'notes', 'automatic cancellation'],
    'book'               => ['book', 'notes', 'automatic cancellation'],
    'thesis'             => ['thesis', 'notes', 'automatic cancellation'],
    'report'             => ['report', 'host', 'notes', 'automatic cancellation'],
    'standard'           => ['standard', 'notes', 'automatic cancellation'],
    'patent'             => ['patent'],
    'other'              => ['other', 'host', 'notes', 'automatic cancellation'],
  }
end

def valid_section_data
  {
    'article' => {
      'Title'  => 'Article Title',
      'Author' => 'Article Author',
      'DOI'    => '10.1000/article-doi'
    },
    'journal' => {
      'Title'  => 'Journal Title',
      'ISSN'   => '12345678',
      'Volume' => '1',
      'Issue'  => '2',
      'Year'   => '1999',
      'Pages'  => '10-11'
    },
    'host' => {
      'Title'        => 'Host Title',
      'ISSN or ISBN' => '12345678',
      'Volume'       => '1',
      'Issue'        => '2',
      'Year'         => '1999',
      'Pages'        => '10-11'
    },
    'notes' => {
      'Notes' => 'User notes'
    },
    'proceedings' => {
      'Title'     => 'Proceedings Title',
    },
    'conference' => {
      'Title'        => 'Conference Title',
      'Location'     => 'Conference Location',
      'Year'         => '2001',
      'ISSN or ISBN' => '1234567890123',
      'Pages'        => '13-14'
    },
    'book' => {
      'Title'     => 'Book Title',
      'Author'    => 'Book Author',
      'Edition'   => '2',
      'DOI'       => '10.1000/book-doi',
      'ISBN'      => '1234567890123',
      'Year'      => '1999',
      'Publisher' => 'Publisher Name'
    },
    'thesis' => {
      'Title'       => 'Thesis Title',
      'Author'      => 'Thesis Author',
      'Affiliation' => 'Thesis Affiliation',
      'Publisher'   => 'Thesis Publisher',
      'Type'        => 'PhD',
      'Year'        => '1999',
      'Pages'       => '10-12'
    },
    'report' => {
      'Title'         => 'Report Title',
      'Author'        => 'Report Author',
      'Publisher'     => 'Report Publisher',
      'DOI'           => '10.1000/report-doi',
      'Report Number' => '101010'
    },
    'standard' => {
      'Title'           => 'Standard Title',
      'Subtitle'        => 'Standard Subtitle',
      'Publisher'       => 'Standard Publisher',
      'DOI'             => '10.1000/standard-doi',
      'Standard Number' => '101010',
      'ISBN'            => '1234567890123',
      'Year'            => '1999',
      'Pages'           => '10-12'
    },
    'patent' => {
      'Title'         => 'Patent Title',
      'Inventor'      => 'Patent Inventor',
      'Patent Number' => '101010',
      'Year'          => '1999',
      'Country'       => 'Patent Country'
    },
    'other' => {
      'Title'     => 'Other Title',
      'Author'    => 'Other Author',
      'Publisher' => 'Other Publisher',
      'DOI'       => '10.1000/other-doi'
    }
  }
end

# Fields prefixed with "r:" are required and fields prefixed with "o:" are optional
def _section_fields
  {
    'article'     => ['r:Title', 'o:Author', 'o:DOI'],
    'journal'     => ['r:Title', 'o:ISSN', 'r:Volume', 'o:Issue', 'r:Year', 'r:Pages'],
    'host'        => ['o:Title', 'o:ISSN or ISBN', 'o:Volume', 'o:Issue', 'r:Year', 'o:Pages'],
    'auto-cancel' => ['o:Automatic cancellation'],
    'notes'       => ['o:Notes'],
    'conference'  => ['r:Title', 'o:Location', 'r:Year', 'o:ISSN or ISBN', 'r:Pages'],
    'book'        => ['r:Title', 'o:Author', 'o:Edition', 'o:DOI', 'o:ISBN', 'r:Year', 'o:Publisher'],
    'thesis'      => ['r:Title', 'r:Author', 'o:Affiliation', 'o:Publisher', 'o:Type', 'r:Year', 'o:Pages'],
    'report'      => ['r:Title', 'o:Author', 'o:Publisher', 'o:DOI', 'o:Report Number'],
    'standard'    => ['r:Title', 'o:Subtitle', 'o:Publisher', 'o:DOI', 'o:Standard Number', 'o:ISBN', 'r:Year', 'o:Pages'],
    'patent'      => ['r:Title', 'o:Inventor', 'o:Patent Number', 'r:Year', 'o:Country'],
    'other'       => ['r:Title', 'o:Author', 'o:Publisher', 'o:DOI']
  }
end

def sections
  _section_fields.keys
end

def section_fields
  result = {}
  sections.each do |section|
    result[section] = _section_fields[section].collect {|e| e[2..-1]}
  end
  result
end

def required_section_fields
  result = {}
  sections.each do |section|
    result[section] = _section_fields[section].select {|e| e[0..1] == 'r:'}.collect {|e| e[2..-1]}
  end
  result
end

def optional_section_fields
  result = {}
  sections.each do |section|
    result[section] = _section_fields[section].select {|e| e[0..1] == 'o:'}.collect {|e| e[2..-1]}
  end
  result
end
