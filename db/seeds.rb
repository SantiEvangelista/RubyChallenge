# db/seeds.rb
require_relative '../config/environment'
require_relative '../app/models/product'
require 'active_support/core_ext/numeric/time' # Para usar 3.minutes

puts "Seeding database with products..."

# Clear existing products to avoid duplicates on re-seeding
Product.destroy_all

Product.create!(name: "Laptop", author: "Admin", date_published: DateTime.now)
Product.create!(name: "Mouse", author: "Admin", date_published: DateTime.now - 1.minute)
Product.create!(name: "Keyboard", author: "Admin", date_published: DateTime.now - 2.minutes)
Product.create!(name: "Monitor", author: "User", date_published: DateTime.now - 3.minutes)

puts "Seeding complete! Created #{Product.count} products."
