module Toshokan
  module Orders
    extend ActiveSupport::Concern

    included do
      include Toshokan::Orders::FilterQueries
      include Toshokan::Orders::Facets
      include Toshokan::Orders::QueryParams
    end
  end
end
