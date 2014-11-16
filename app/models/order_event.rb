class OrderEvent < ActiveRecord::Base
  belongs_to :order

  #attr_accessible :name, :data
end
