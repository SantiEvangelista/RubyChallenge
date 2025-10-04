# spec/actions/product_actions_spec.rb
require_relative '../spec_helper'
require_relative '../../app/actions/list_products'
require_relative '../../app/actions/create_product'
require_relative '../../app/actions/show_product' # Añadir la acción ShowProduct
require_relative '../../app/models/product' # Necesario para interactuar con la BD

RSpec.describe "Product Actions" do
  # Limpiar la base de datos antes de cada test
  before(:each) do
    Product.destroy_all
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
    describe ".call" do
      context "with valid product parameters" do
        let(:valid_params) { { name: "New Product", author: "New Author", date_published: DateTime.now } }

        it "creates a new product" do
          expect { Actions::CreateProduct.call(valid_params) }.to change(Product, :count).by(1)
        end

        it "returns the created product" do
          product = Actions::CreateProduct.call(valid_params)
          expect(product).to be_a(Product)
          expect(product.name).to eq("New Product")
          expect(product.author).to eq("New Author")
        end
      end

      context "with invalid product parameters" do
        let(:invalid_params) { { name: "", author: "New Author" } }

        it "does not create a product" do
          expect { Actions::CreateProduct.call(invalid_params) }.to_not change(Product, :count)
        end

        it "returns an error message" do
          result = Actions::CreateProduct.call(invalid_params)
          expect(result).to be_a(Hash)
          expect(result[:errors]).to include("Name can't be blank")
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
end
