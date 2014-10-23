class Progress < ActiveRecord::Base
  attr_accessible :current, :end, :finished, :name, :start, :stop
end
