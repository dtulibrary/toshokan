Given /^the database has been seeded$/ do
  include File.join Rails.root, 'db/seeds.rb' unless Role.count > 0
end
