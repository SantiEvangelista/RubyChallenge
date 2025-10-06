# spec/swagger_helper.rb
require 'spec_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured, as the files are written to the
  # swagger_root (e.g. swagger/v1/swagger.yaml)
  config.swagger_root = File.join(File.dirname(__FILE__), '..', 'swagger')

  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.3',
      info: {
        title: 'FUDO - Ruby Challenge API by Santiago Evangelista',
        version: 'v1',
        description: 'API REST implementada en Ruby con Sinatra que expone endpoints para autenticación JWT y gestión asíncrona de productos.',
        contact: {
          name: 'Santiago Evangelista'
        }
      },
      servers: [
        {
          url: 'http://localhost:8080'
        }
      ],
      tags: [
        {
          name: 'Authentication',
          description: 'Endpoints de autenticación y autorización'
        },
        {
          name: 'Products',
          description: 'Endpoints para gestión de productos'
        },
        {
          name: 'Jobs',
          description: 'Endpoints para consultar estado de tareas asíncronas'
        }
      ],
      components: {
        securitySchemes: {
          BearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'Token JWT obtenido del endpoint /login'
          }
        },
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end

