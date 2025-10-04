# app/jobs/product_job.rb
require 'securerandom'
require_relative '../../config/environment'
require_relative '../models/product'

module Jobs
  class ProductJob
    # Hash simple para almacenar jobs en memoria
    @@jobs = {}
    
    class << self
      # Crear un nuevo job asíncrono
      def create_async(product_params, delay_seconds = 5)
        job_id = SecureRandom.uuid
        request_time = Time.current
        
        # Validar delay máximo de 2 minutos
        delay_seconds = [delay_seconds.to_i, 120].min
        delay_seconds = [delay_seconds, 1].max # Mínimo 1 segundo
        
        # Guardar job en memoria
        @@jobs[job_id] = {
          status: 'pending',
          created_at: request_time,
          estimated_completion: request_time + delay_seconds,
          delay_seconds: delay_seconds,
          product_params: product_params
        }
        
        # Iniciar job en background
        Thread.new do
          execute_job(job_id, delay_seconds)
        end
        
        {
          job_id: job_id,
          status: 'pending',
          estimated_completion: request_time + delay_seconds,
          delay_seconds: delay_seconds
        }
      end
      
      # Obtener estado de un job
      def get_status(job_id)
        job = @@jobs[job_id]
        return nil unless job
        
        {
          job_id: job_id,
          status: job[:status],
          created_at: job[:created_at],
          estimated_completion: job[:estimated_completion],
          delay_seconds: job[:delay_seconds]
        }
      end
      
      private
      
      # Ejecutar el job con delay
      def execute_job(job_id, delay_seconds)
        job = @@jobs[job_id]
        return unless job
        
        begin
          # Marcar como procesando
          @@jobs[job_id][:status] = 'processing'
          
          # Esperar el delay especificado
          sleep(delay_seconds)
          
          # Crear el producto en la base de datos
          product = Product.create!(job[:product_params])
          
          # Marcar como completado
          @@jobs[job_id][:status] = 'completed'
          @@jobs[job_id][:product_id] = product.id
          @@jobs[job_id][:completed_at] = Time.current
          
        rescue => e
          # Marcar como fallido
          @@jobs[job_id][:status] = 'failed'
          @@jobs[job_id][:error] = e.message
          @@jobs[job_id][:failed_at] = Time.current
        end
      end
    end
  end
end
