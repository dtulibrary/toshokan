class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :bookmark

  attr_accessible :bookmark, :tag
end