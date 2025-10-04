# app/actions/create_product.rb
require_relative '../../config/environment'
require_relative '../models/product'
require_relative '../jobs/product_job'

module Actions
  class CreateProduct
    def self.call(product_params, delay_seconds = 5)
      # Agregar timestamp de request (date_published) ANTES de validar
      product_params[:date_published] = Time.current
      product_params[:status] = 'pending' # Estado inicial
      
      # Validar parámetros antes de crear el job
      product = Product.new(product_params)
      unless product.valid?
        return { success: false, errors: product.errors.full_messages }
      end
      
      # Crear job asíncrono
      result = Jobs::ProductJob.create_async(product_params, delay_seconds)
      result[:success] = true
      result
    rescue => e
      { success: false, error: e.message }
    end
  end
end
