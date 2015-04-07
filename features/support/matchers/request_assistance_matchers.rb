RSpec::Matchers.define :have_sections do |sections|
  match do |page|
    result = sections.all? {|s| page.has_css? ".#{s.gsub ' ', '-'}-section"}
  end

  failure_message do |page|
    "Expected to find sections #{sections} but found #{sections.select {|s| page.has_css? ".#{s.gsub ' ', '-'}-section"}} in #{page.body.blank? ? '(empty page body)' : "\n#{page.body}"}"
  end
end
