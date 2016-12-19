class QueryResultDocument < ActiveRecord::Base
  belongs_to :query

  serialize :document,  JSON
  serialize :duplicate, JSON
end
