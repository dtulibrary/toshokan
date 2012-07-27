# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.create([{name: 'Administrator', code: 'ADM'},{name: 'Cataloger', code: 'CAT'},
  {name: 'User Support', code: 'SUP'}, {name: 'Metadata Access', code: 'DAT'}])
