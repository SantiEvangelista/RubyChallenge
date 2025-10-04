# spec/actions/product_actions_spec.rb
require_relative '../spec_helper'
require_relative '../../app/actions/list_products'
require_relative '../../app/actions/create_product'
require_relative '../../app/actions/show_product'
require_relative '../../app/actions/get_job_status'
require_relative '../../app/models/product'

RSpec.describe "Product Actions" do
  # Limpiar la base de datos antes de cada test
  before(:each) do
    # Esperar a que terminen jobs anteriores
    sleep(0.5)
    Product.destroy_all
    Jobs::ProductJob.clear_jobs
  end

  # Asegurar que todos los threads terminen después de cada test
  after(:each) do
    sleep(0.5)
    Product.destroy_all
    Jobs::ProductJob.clear_jobs
  end

  describe Actions::ListProducts do
    describe ".call" do
      it "returns an empty array if no products exist" do
        expect(Actions::ListProducts.call).to be_empty
      end

      it "returns all existing products" do
        Product.create!(name: "Product 1", author: "Author A", date_published: DateTime.now)
        Product.create!(name: "Product 2", author: "Author B", date_published: DateTime.now)

        products = Actions::ListProducts.call
        expect(products.count).to eq(2)
        expect(products.map(&:name)).to include("Product 1", "Product 2")
      end
    end
  end

  describe Actions::CreateProduct do
    describe ".call (asynchronous)" do
      context "with valid product parameters" do
        let(:valid_params) { { name: "New Product", author: "New Author" } }

        it "returns success with job_id and does not create product immediately" do
          result = Actions::CreateProduct.call(valid_params, 1)
          
          expect(result[:success]).to be true
          expect(result[:job_id]).to be_a(String)
          expect(result[:status]).to eq("pending")
          expect(result[:delay_seconds]).to eq(1)
          expect(Product.count).to eq(0) # No se crea inmediatamente
        end

        it "creates the product after the delay" do
          # Asegurar que no hay productos antes de empezar
          Product.destroy_all
          expect(Product.count).to eq(0)
          
          result = Actions::CreateProduct.call(valid_params, 1)
          expect(Product.count).to eq(0)
          
          # Esperar a que se complete el job
          sleep(2)
          
          # Recargar desde la base de datos
          products = Product.all.to_a
          expect(products.count).to eq(1)
          product = products.first
          expect(product.name).to eq("New Product")
          expect(product.author).to eq("New Author")
          expect(product.status).to eq("completed")
          expect(product.date_published).to be_present
          
          # Limpiar después del test
          Product.destroy_all
        end

        it "sets date_published automatically" do
          Product.destroy_all
          before_time = Time.current
          result = Actions::CreateProduct.call(valid_params, 1)
          sleep(2)
          
          product = Product.first
          expect(product.date_published).to be >= before_time
          expect(product.date_published).to be < product.created_at
          
          Product.destroy_all
        end
      end

      context "with invalid product parameters" do
        let(:invalid_params) { { name: "", author: "New Author" } }

        it "does not create a job or product" do
          result = Actions::CreateProduct.call(invalid_params)
          
          expect(result[:success]).to be false
          expect(result[:errors]).to include("Name can't be blank")
          expect(Product.count).to eq(0)
        end

        it "returns validation errors" do
          result = Actions::CreateProduct.call({ author: "Author" })
          
          expect(result).to be_a(Hash)
          expect(result[:success]).to be false
          expect(result[:errors]).to be_an(Array)
        end
      end
    end
  end

  describe Actions::ShowProduct do
    describe ".call" do
      it "returns the product if found" do
        product = Product.create!(name: "Find Me", author: "Finder", date_published: DateTime.now)
        found_product = Actions::ShowProduct.call(product.id)
        expect(found_product).to eq(product)
      end

      it "returns nil if the product is not found" do
        found_product = Actions::ShowProduct.call(99999) # Un ID que no existe
        expect(found_product).to be_nil
      end
    end
  end

  describe Actions::GetJobStatus do
    describe ".call" do
      context "with valid job_id" do
        it "returns job status information" do
          # Crear un job
          create_result = Actions::CreateProduct.call({ name: "Test", author: "Tester" }, 2)
          job_id = create_result[:job_id]
          
          # Obtener estado del job
          status_result = Actions::GetJobStatus.call(job_id)
          
          expect(status_result[:job_id]).to eq(job_id)
          expect(status_result[:status]).to be_a(String)
          expect(status_result[:created_at]).to be_present
          expect(status_result[:estimated_completion]).to be_present
        end

        it "shows pending status immediately after creation" do
          create_result = Actions::CreateProduct.call({ name: "Test", author: "Tester" }, 2)
          status_result = Actions::GetJobStatus.call(create_result[:job_id])
          
          expect(status_result[:status]).to eq("pending")
        end

        it "shows completed status after delay" do
          Product.destroy_all
          create_result = Actions::CreateProduct.call({ name: "Test", author: "Tester" }, 1)
          job_id = create_result[:job_id]
          
          sleep(2)
          
          status_result = Actions::GetJobStatus.call(job_id)
          expect(status_result[:status]).to eq("completed")
          
          Product.destroy_all
        end
      end

      context "with invalid job_id" do
        it "returns error for non-existent job" do
          result = Actions::GetJobStatus.call("invalid-uuid")
          
          expect(result[:error]).to eq("Job not found")
        end
      end
    end
  end
end
