module BlacklightTag::User

  module ClassMethods

  end

  module InstanceMethods
    def tag(document)

    end
  end

  def self.included(base)
    base.send :has_many, :tags, :as => :user
    base.send :has_many, :subscriptions, :as => :user

    base.send :has_many, :owned_tags, :source => :tags, :as => :user
    base.send :has_many, :shared_tags, :source => :tags, :conditions => {"shared" => true}, :as => :user
    base.send :has_many, :subscribed_tags, :through => :subscriptions, :source => :tags, :conditions => {"shared" => true}, :as => :user

    base.extend         ClassMethods
    base.send :include, InstanceMethods
  end
end