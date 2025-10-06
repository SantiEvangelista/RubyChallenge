# spec/integration/jobs_spec.rb
require 'swagger_helper'

RSpec.describe 'Jobs API', type: :request do
  let(:token) { Actions::AuthenticateUser.call('admin', 'secret')[:token] }
  let(:Authorization) { "Bearer #{token}" }

  path '/products/jobs/{job_id}' do
    parameter name: :job_id, in: :path, type: :string, format: :uuid,
      description: 'UUID del job'

    get 'Consultar estado de job de creación de producto' do
      tags 'Jobs'
      produces 'application/json'
      description 'Consulta el estado de un job asíncrono de creación de producto. Estados posibles: pending, processing, completed, failed.'
      security [BearerAuth: []]

      response '200', 'Estado del job' do
        schema '$ref' => '#/components/schemas/JobStatus'

        let(:job_id) do
          # Create a job first
          product_params = { name: 'Test Job Product', author: 'Test Author' }
          result = Actions::CreateProduct.call(product_params, 5)
          result[:job_id]
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['job_id']).to be_present
          expect(data['status']).to be_in(['pending', 'processing', 'completed', 'failed'])
          expect(data['created_at']).to be_present
          expect(data['estimated_completion']).to be_present
          expect(data['delay_seconds']).to be_present
        end
      end

      response '404', 'Job no encontrado' do
        schema type: :object,
          properties: {
            error: { type: :string, example: 'Job not found' }
          }

        let(:job_id) { '550e8400-e29b-41d4-a716-446655440000' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Job not found')
        end
      end

      response '401', 'No autenticado' do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:Authorization) { nil }
        let(:job_id) { '550e8400-e29b-41d4-a716-446655440000' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('No token provided')
        end
      end
    end
  end
end

