# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

{ 
  ADM: 'Administrator',
  CAT: 'Cataloger',
  SUP: 'User Support',
  DAT: 'Metadata Access'
}.each do |code, name|
  Role.create :code => code.to_s, :name => name unless Role.exists? :code => code.to_s
end
