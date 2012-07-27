require 'singleton'

module Dtubase
  class Configuration
    def add_mock(username, mock)
      @mock_account[username.to_sym] = mock
    end

    def initialize
      @mock_account = Hash.new
    end

    attr_accessor :test_mode, :mock_account, :url, :username, :password
  end

  def self.config
    @@configuration ||= Configuration.new
  end

  def self.configure
    yield self.config
  end

  def self.mock_account_for(user_name)
    self.config.mock_account[user_name.to_sym]
  end

end
