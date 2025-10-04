# app/actions/show_product.rb
require_relative '../../config/environment'
require_relative '../models/product'

module Actions
  class ShowProduct
    def self.call(id)
      Product.find_by(id: id)
    end
  end
end
