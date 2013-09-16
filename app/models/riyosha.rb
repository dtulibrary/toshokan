require 'singleton'

module Riyosha
  class Configuration
    def add_mock(identifier, mock)
      @mock_user_data[identifier.to_sym] = mock
    end

    def initialize
      @mock_user_data = Hash.new
    end

    attr_accessor :test_mode, :mock_user_data, :url
  end

  def self.config
    @@configuration ||= Configuration.new
  end

  def self.configure
    yield self.config
  end

  def self.mock_user_data_for(identifier)
    self.config.mock_user_data[identifier.to_sym]
  end


  def self.find(identifier)
    config = Riyosha.config
    if (config.test_mode)
      Riyosha.mock_user_data_for(identifier)
    else
      JSON.parse(HTTParty.get(Rails.application.config.auth[:api_url] + "/users/#{identifier}.json").body)
    end
  rescue Exception => e
    nil
  end

  def self.find_or_create_by_cwis(cwis)
    config = Riyosha.config
    if (config.test_mode)
      Riyosha.mock_user_data_for(cwis)
    else
      JSON.parse(HTTParty.get(Rails.application.config.auth[:api_url] + "/create_dtu/#{cwis}.json").body)
    end
  rescue Exception => e
    nil
  end

end
