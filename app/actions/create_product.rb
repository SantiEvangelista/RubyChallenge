# app/actions/create_product.rb
require_relative '../../config/environment'
require_relative '../models/product'

module Actions
  class CreateProduct
    def self.call(product_params)
      Product.create(product_params)
    rescue ActiveRecord::RecordInvalid => e
      { errors: e.record.errors.full_messages }
    end
  end
end
