
require 'active_record'

# Cargar el entorno de ActiveRecord (conexión a la base de datos)
require_relative '../../config/environment'

class Product < ActiveRecord::Base
  # Validaciones (opcional, pero buena práctica)
  validates :name, presence: true
  validates :author, presence: true
  validates :date_published, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending processing completed failed] }

  # Estados posibles del producto
  STATUSES = %w[pending processing completed failed].freeze

  # Métodos helper para verificar estados
  def pending?
    status == 'pending'
  end

  def processing?
    status == 'processing'
  end

  def completed?
    status == 'completed'
  end

  def failed?
    status == 'failed'
  end
end
