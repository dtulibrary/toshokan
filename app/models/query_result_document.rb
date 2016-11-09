class QueryResultDocument < ActiveRecord::Base
  belongs_to :query

  validates :document, presence: true

  serialize :document,  JSON
  serialize :duplicate, JSON
end
