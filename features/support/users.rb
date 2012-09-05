def find_user key, value
  key = 'identifier' if key == 'cwis'
  User.send 'find_by_' + key, value
end
