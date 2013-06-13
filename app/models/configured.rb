# Module for connecting a class with the Rails configuration for easy access.
# 
# For a class MyModule::MyClass including this module it expects rails.application.config.my_class
# to be a hash. It adds/overrides method_missing to the including class.
# (note: it only uses the simple name of the including class for lookup in the Rails configuration
# and not the names of any modules or encapsulating classes)
#
# Example:
# ---
# application.rb:
#   config.dibs.url = 'dibs-url'
#
# ---
# app/models/dibs.rb:
#   class Dibs
#     include Configured
#     
#     def do_stuff
#       HTTParty.post Dibs.url, :body => {}
#     end
#   end

module Configured
  def Configured.included base
    class << base
      def method_missing method, *args
        Rails.application.config.send(self.name.split(/::/).last.gsub(/([a-z])([A-Z])/, '\1_\2').downcase)[method.to_s.gsub(/\?$/, '').to_sym]
      end
    end
  end
end
