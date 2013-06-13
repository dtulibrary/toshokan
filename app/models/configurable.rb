require 'hashie'

module Configurable
  def Configurable.included base
    class << base
      def config
        @config ||= Hashie::Mash.new
      end

      def configure &block
        yield self.config
      end
    end
  end
end

=begin

# Example usage

class SendIt 
  include Configurable

  def self.send_mail
    puts config.url
  end
end

# Initializer code

SendIt.configure do |config|
  config.url = 'http://url.dk'
end

=end
