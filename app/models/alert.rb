class Alert
  extend ActiveModel::Naming
  include ActiveModel::Conversion  
  include ActiveModel::Validations
  include HTTParty
  include Configured

  base_uri Alert.url

  attr_accessor :frequency, :user_id, :alert_type, :name, :query, :created_at, :updated_at, :id, :reference
  #attr_accessible :alert_type, :query, :name

  validates_presence_of :query, :alert_type, :user_id

  def initialize(attributes = {}, user = nil)
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    @alert_type ||= "journal"
    @frequency ||= 7
    @user_id = user.identifier unless user.nil?
  end

  def save
    begin
      response = self.class.post("/alerts", {:body => attributes})
      if response.success?
        self.id = ActiveSupport::JSON.decode(response.body)["alert"]["id"]        
      else
        Rails.logger.error "Alert service failed on saving alert for #{self.inspect} with #{response.message} and status #{response.code}"
      end    
      response.success?
    rescue Timeout::Error
      Rails.logger.error "Alert service timed out"
      false
     end    
  end

  def self.destroy(id)
    begin
      response = self.delete("/alerts/#{id}")
      unless response.success?
        Rails.logger.error "Alert service failed on deleting alert for id #{id} with #{response.message} and status #{response.code}"
      end
      response.success?
    rescue Timeout::Error
      Rails.logger.error "Alert service timed out"
      false
    end        
  end

  def self.all(user, type)
    return [] if Alert.test_mode
    alerts = nil
    begin
      response = self.get("/alerts", :query => {"user_id" => user.identifier, "alert_type" => type})
      if response.success?
        alerts = []
        ActiveSupport::JSON.decode(response.body).each do |a|        
          alerts << Alert.new(a["alert"])
        end
      else
        Rails.logger.error "Alert service failed on getting alerts for user #{user.inspect} and type #{type} with '#{response.message}'"
      end
    rescue Timeout::Error
      Rails.logger.error "Alert service timed out"
    end        
    alerts
  end

  def self.lookup(id)
    return nil if Alert.test_mode
    begin
      response = self.get("/alerts/#{id}")    
      if response.success?
        alert = Alert.new(ActiveSupport::JSON.decode(response.body)["alert"])
      else
        if response.code == 404
          Rails.logger.error "Alert service could not find alert with id #{id}"
        else
          Rails.logger.error "Alert service failed on lookup request on id #{id} with '#{response.message}'"
        end
      end
    rescue Timeout::Error
      Rails.logger.error "Alert service timed out"
    end   
    alert
  end

  def self.find(user, query_params = {})
    return nil if Alert.test_mode
    begin
      query_params[:user_id] = user.identifier
      response = self.get("/alerts/find", :query => {:find => query_params})
      if response.success?
        alert = Alert.new(ActiveSupport::JSON.decode(response.body)["alert"])
      else
        if response.code != 404
          Rails.logger.error "Alert service failed on find request for user #{user.inspect} and query '#{query_params}' with '#{response.message}'"
        end
      end
    rescue Timeout::Error
      Rails.logger.error "Alert service timed out"
    end   
    alert 
  end

  def persisted?
    false
  end

  private

  def attributes
    attributes = {}
    self.instance_variables.each do |attr|
      attributes[attr.to_s.delete("@")] = self.instance_variable_get(attr)
    end
    {self.class.to_s.downcase => attributes}
  end

end
