load File.dirname(__FILE__) + '/production.rb'

if File.exists? File.dirname(__FILE__) + '/../application.local.rb'
  require File.dirname(__FILE__) + '/../application.local.rb'
end
