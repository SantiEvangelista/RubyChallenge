
require 'active_record'

# Cargar el entorno de ActiveRecord (conexión a la base de datos)
require_relative '../../config/environment'

class Product < ActiveRecord::Base
  # Validaciones (opcional, pero buena práctica)
  validates :name, presence: true
  validates :author, presence: true
  validates :date_published, presence: true
end
