# spec/integration/authentication_spec.rb
require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  path '/login' do
    post 'Autenticar usuario y obtener token JWT' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      description 'Valida credenciales de usuario y retorna un token JWT para autenticación'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          username: { type: :string, example: 'admin' },
          password: { type: :string, format: :password, example: 'secret' }
        },
        required: ['username', 'password']
      }

      response '200', 'Autenticación exitosa' do
        schema type: :object,
          properties: {
            access: { type: :string, example: 'granted' },
            token: { type: :string, example: 'eyJhbGciOiJIUzI1NiJ9...' }
          },
          required: ['access', 'token']

        let(:credentials) { { username: 'admin', password: 'secret' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['access']).to eq('granted')
          expect(data['token']).to be_present
        end
      end

      response '401', 'Credenciales inválidas' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:credentials) { { username: 'admin', password: 'wrong' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['access']).to eq('denied')
          expect(data['error']).to eq('Invalid credentials')
        end
      end
    end
  end

  path '/test_auth' do
    get 'Verificar token JWT' do
      tags 'Authentication'
      produces 'application/json'
      description 'Endpoint de prueba para verificar que el token JWT es válido'
      security [BearerAuth: []]

      response '200', 'Token válido' do
        schema type: :object,
          properties: {
            message: { type: :string, example: 'Welcome, admin! You are authenticated.' }
          }

        let(:token) { Actions::AuthenticateUser.call('admin', 'secret')[:token] }
        let(:Authorization) { "Bearer #{token}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to include('Welcome')
          expect(data['message']).to include('authenticated')
        end
      end

      response '401', 'Token inválido o no proporcionado' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { 'Bearer invalid_token' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to be_present
        end
      end

      response '401', 'Sin token' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('No token provided')
        end
      end
    end
  end
end

