Given /^I(?:'m| am) on the "request assistance" form$/ do
  visit new_assistance_request_path
end

Given /^I(?:'m| am) on the "request assistance" form for "(.*?)"$/ do |genre|
  @genre = genre
  visit new_assistance_request_path(:genre => genre.gsub(' ', '_'))
end

{ 
  'journal article'    => ['article', 'journal', 'notes'],
  'conference article' => ['article', 'conference', 'notes'],
  'book'               => ['book', 'notes']
}.each do |genre, sections|
  Given %r{^I(?:'ve| have) submitted a valid assistance request for "#{genre}"$} do 
    step %{I'm on the "request assistance" form for "#{genre}"}
    sections.each do |section|
      step %{I fill in the "#{section}" form section with valid data}
    end
    step %{I click "Send request"}
  end
  
  Then %r{^I should see the "request assistance" confirmation page for "#{genre}"$} do
    step %{I should see "Please confirm your assistance request"}
    sections.each do |section|
      step %{I should see the "#{section}" section with the submitted data}
    end
  end

  Then %r{^I should(n't| not)? see the "request assistance" form for "#{genre}"$} do |negate|
    check_form_correctness sections, negate
    step %{I should see the "Send request" and "Clear" buttons}
  end
end

When /^I go to the "request assistance" form for "(.*?)"$/ do |genre|
  step %{I'm on the "request assistance" form for "#{genre}"}
end

When /^I go to the "request assistance" form$/ do
  step %{I'm on the "request assistance" form}
end

When /^I fill in the (".*") form sections with valid data$/ do |sections|
  sections.scan /"(.*?)"/ do |section, _|
    step %{I fill in the "#{section}" form section with valid data}
  end
end

When /^I fill in the "request assistance" form with valid data$/ do
  step %{I fill in the #{form_sections[@genre].collect {|s| "\"#{s}\""}.join ','} form sections with valid data}
end

When /^I select pickup location "(.*?)"$/ do |location|
  within locator_for_section('pickup-location') do
    check(location)
    submitted_data['pickup_location'] = location
  end
end

Then /^I should see the (".*") form sections with the submitted$/ do |sections|
  sections.scan /"(.*?)"/ do |section, _|
    step %{I should see the "#{section}" form section with the submitted data}
  end
end

Then /^I should see the (".*") sections with the submitted data$/ do |sections|
  sections.scan /"(.*?)"/ do |section, _|
    step %{I should see the "#{section}" section with the submitted data}
  end
end

['article', 'journal', 'notes', 'conference', 'book', 'publisher'].each do |section|
  When %r{^I fill in the "#{section}" form section with valid data$} do
    submitted_data[section] = valid_section_data[section]
    fill_in_section section, submitted_data[section]
  end

  Then %r{^I should see the "#{section}" form section with the submitted data$} do
    within locator_for_section(section) do
      submitted_data[section].each do |field, value|
        find_field(field).value.should == value
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

Then /^I should see the "physical location" section with the submitted data$/ do
  within locator_for_section('physical-location') do
    @current_user.user_data['address'].reject {|k,v| v.blank? || k == 'country'}.each do |k,v|
      step %{I should see "#{v}"}
    end
  end
end

Then /^I should see the "pickup location" section with the submitted data$/ do
  within locator_for_section('pickup-location') do
    step %{I should see "Pick-up location"}
    step %{I should see "#{submitted_data['pickup_location']}"}
  end
end

Then /^I should(n't| not)? see the "request assistance" form links$/ do |negate|
  step %{I should#{negate} see the "Journal article" link}
  step %{I should#{negate} see the "Conference article" link}
  step %{I should#{negate} see the "Book" link}
end

Then /^I should see the (".*") buttons$/ do |buttons|
  buttons.scan /"(.*?)"/ do |button,_|
    step %{I should see the "#{button}" button}
  end
end

Then /^I should see the "(.*?)" button$/ do |button|
  page.should have_button(button)
end

Then /^I should(?:n't| not) see the "(.*?)" section$/ do |section|
  page.should_not have_sections([section])
end

Then /^I should see the "(article|journal|notes|conference|book|publisher)" section$/ do |section|
  within locator_for_section(section) do
    section_fields[section].each do |field_label|
      step %{I should see "#{field_label}"}
    end
  end
end

Then /^I should see the "email" section$/ do
  within '.email-section' do
    step %{I should see "Email"}
  end
end

Then /^I should see the "physical location" section$/ do
  within '.physical-location-section' do
    step %{I should see "Physical location"}
  end
end

Then /^I should see the "pickup location" section$/ do
  within '.pickup-location-section' do
    step %{I should see "Lyngby"}
    step %{I should see "Ballerup"}
  end
end

Then /^I should see the proper required fields in the "(.*?)" section$/ do |section|
  (required_section_fields[section] || []).each do |required_field|
    within locator_for_section(section) do
      # The following is really ugly but neither of
      # find_field(required_field).should have_css('.required')
      # (find_field(required_field)['class'] || '').split.should include?('required')
      # worked for me so this is the current working solution
      (find_field(required_field)['class'] || '').split.any? {|c| c == 'required'}.should be_true
    end
  end
end

Then /^I should see the proper optional fields in the "(.*?)" section$/ do |section|
  (optional_section_fields[section] || []).each do |optional_field|
    within locator_for_section(section) do
      # See comment from step for required fields
      (find_field(optional_field)['class'] || '').split.any? {|c| c == 'required'}.should be_false
    end
  end
end

Then /^I should see errors in the (".*") fields in the "(.*?)" form section$/ do |fields, section|
  fields.scan /"(.*?)"/ do |field, _|
    step %{I should see an error in the "#{field}" field in the "#{section}" form section}
  end
end

Then /^I should see an error in the "(.*?)" field in the "(.*?)" form section$/ do |field, section|
  within locator_for_section(section) do
    (find_field(field)['class'] || '').split.any? {|c| c == 'error'}.should be_true
  end
end

Then /^I should see the submitted data$/ do
  submitted_data.each do |section, fields|
    fields.each do |field, value|
      step %{I should see "#{field}"}
      step %{I should see "#{value}"}
    end
  end
end

def check_form_correctness sections, negate = false
  if negate
    page.should_not have_sections(sections)
  else
    page.should have_sections(sections)
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
  within ".#{section.gsub ' ', '-'}-section" do 
    fields.each do |field, value|
      step %{I fill in "#{field}" with "#{value}"}
    end
  end
end

def form_sections
  {
    'journal article'    => ['article', 'journal', 'notes'],
    'conference article' => ['article', 'conference', 'notes'],
    'book'               => ['book', 'notes']
  }
end

def valid_section_data
  { 
    'article' => {
      'Title'  => 'An article about stuff',
      'Author' => 'Some Dude',
      'DOI'    => '10.1000/12345678'
    },
    'journal' => {
      'Title'  => 'Most interesting journal',
      'ISSN'   => '12345678',
      'Volume' => '3',
      'Issue'  => '1',
      'Year'   => '1999',
      'Pages'  => '12-14'
    },
    'notes' => {
      'Notes' => 'I hereby note, that I have nothing to note.'
    },
    'proceedings' => {
      'Title'     => 'Proceedings on conference on stuff',
    },
    'conference' => {
      'Title'        => 'Conference on stuff',
      'Location'     => 'London',
      'Year'         => '2001',
      'ISSN or ISBN' => '1234567890123',
      'Pages'        => '13-14'
    },
    'book' => {
      'Title'     => 'Stuff: The super bible',
      'Author'    => 'Dude that wrote a book',
      'Edition'   => '2',
      'DOI'       => '10.1000/12345678',
      'ISBN'      => '1234567890123',
      'Year'      => '1999',
      'Publisher' => 'Stuffed Publishers Ltd.'
    }
  }
end

def _section_fields
  {
    'article' => [
      {:title => 'Title',  :required => true},
      {:title => 'Author', :required => false},
      {:title => 'DOI',    :required => false}
    ],
    'journal' => [
      {:title => 'Title',  :required => true},
      {:title => 'ISSN',   :required => false},
      {:title => 'Volume', :required => true},
      {:title => 'Issue',  :required => true},
      {:title => 'Year',   :required => true},
      {:title => 'Pages',  :required => true}
    ],
    'notes' => [
      {:title => 'Notes', :required => false}
    ],
    'conference' => [
      {:title => 'Title',        :required => true},
      {:title => 'Location',     :required => false},
      {:title => 'Year',         :required => true},
      {:title => 'ISSN or ISBN', :required => false},
      {:title => 'Pages',        :required => true}
    ],
    'book' => [
      {:title => 'Title',     :required => true},
      {:title => 'Author',    :required => false},
      {:title => 'Edition',   :required => false},
      {:title => 'DOI',       :required => false},
      {:title => 'ISBN',      :required => false},
      {:title => 'Year',      :required => true},
      {:title => 'Publisher', :required => false}
    ]
  }
end

def sections
  _section_fields.keys
end

def section_fields
  result = {}
  sections.each do |section|
    result[section] = _section_fields[section].collect {|e| e[:title]}
  end
  result
end

def required_section_fields
  result = {}
  sections.each do |section|
    result[section] = _section_fields[section].select {|e| e[:required]}.collect {|e| e[:title]}
  end
  result
end

def optional_section_fields
  result = {}
  sections.each do |section|
    result[section] = _section_fields[section].reject {|e| e[:required]}.collect {|e| e[:title]}
  end
  result
end
