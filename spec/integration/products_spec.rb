# spec/integration/products_spec.rb
require 'swagger_helper'

RSpec.describe 'Products API', type: :request do
  let(:token) { Actions::AuthenticateUser.call('admin', 'secret')[:token] }
  let(:Authorization) { "Bearer #{token}" }

  path '/products' do
    get 'Listar todos los productos' do
      tags 'Products'
      produces 'application/json'
      description 'Retorna una lista de todos los productos en la base de datos'
      security [BearerAuth: []]

      response '200', 'Lista de productos' do
        schema type: :object,
          properties: {
            products: {
              type: :array,
              items: { '$ref' => '#/components/schemas/Product' }
            }
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('products')
          expect(data['products']).to be_an(Array)
        end
      end

      response '401', 'No autenticado' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { nil }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('No token provided')
        end
      end
    end

    post 'Crear producto de forma asíncrona' do
      tags 'Products'
      consumes 'application/json'
      produces 'application/json'
      description 'Crea un producto de forma asíncrona. El producto no se crea inmediatamente, sino después de un delay especificado (default 5 segundos, máximo 120 segundos). Retorna un job_id para consultar el estado de la creación.'
      security [BearerAuth: []]

      parameter name: :delay, in: :query, type: :integer, required: false,
        description: 'Tiempo de espera en segundos antes de crear el producto (1-120)',
        schema: { type: :integer, minimum: 1, maximum: 120, default: 5, example: 10 }

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'Laptop Dell XPS 15' },
          author: { type: :string, example: 'Admin' }
        },
        required: ['name', 'author']
      }

      response '202', 'Job de creación aceptado' do
        schema '$ref' => '#/components/schemas/JobResponse'

        let(:product) { { name: 'Test Product', author: 'Test Author' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(true)
          expect(data['job_id']).to be_present
          expect(data['status']).to eq('pending')
          expect(data['delay_seconds']).to be_present
        end
      end

      response '202', 'Job con delay personalizado' do
        schema '$ref' => '#/components/schemas/JobResponse'

        let(:product) { { name: 'Test Product', author: 'Test Author' } }
        let(:delay) { 10 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['delay_seconds']).to eq(10)
        end
      end

      response '400', 'Datos inválidos' do
        schema '$ref' => '#/components/schemas/ValidationErrorResponse'

        let(:product) { { name: '' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['errors']).to be_present
        end
      end

      response '400', 'Body vacío' do
        schema '$ref' => '#/components/schemas/ValidationErrorResponse'

        let(:product) { nil }

        before do
          header 'Content-Type', 'application/json'
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['success']).to eq(false)
          expect(data['error']).to eq('Request body cannot be empty')
        end
      end

      response '401', 'No autenticado' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { nil }
        let(:product) { { name: 'Test Product', author: 'Test Author' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('No token provided')
        end
      end
    end
  end

  path '/products/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID del producto'

    get 'Obtener producto por ID' do
      tags 'Products'
      produces 'application/json'
      description 'Retorna los detalles de un producto específico'
      security [BearerAuth: []]

      response '200', 'Producto encontrado' do
        schema type: :object,
          properties: {
            product: { '$ref' => '#/components/schemas/Product' }
          }

        let(:id) do
          # Create a test product synchronously for this test
          product = Product.create!(
            name: 'Test Product for Show',
            author: 'Test Author',
            date_published: Time.current,
            status: 'completed'
          )
          product.id
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('product')
          expect(data['product']['id']).to eq(id)
        end
      end

      response '404', 'Producto no encontrado' do
        schema type: :object,
          properties: {
            message: { type: :string, example: 'Product not found' }
          }

        let(:id) { 999999 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Product not found')
        end
      end

      response '401', 'No autenticado' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { nil }
        let(:id) { 1 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('No token provided')
        end
      end
    end
  end
end

