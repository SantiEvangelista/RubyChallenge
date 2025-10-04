# app/actions/list_products.rb
require_relative '../../config/environment'
require_relative '../models/product'

module Actions
  class ListProducts
    def self.call
      Product.all
    end
  end
end
