# db/seeds.rb
require_relative '../config/environment'
require_relative '../app/models/product'

puts "Seeding database with products..."

# Clear existing products to avoid duplicates on re-seeding
Product.destroy_all

Product.create!(name: "Laptop", author: "Admin", date_published:  DateTime.now)
Product.create!(name: "Mouse", author: "Admin", date_published:  DateTime.now - (60 * 1))
Product.create!(name: "Keyboard", author: "Admin", date_published:  DateTime.now - (60 * 2))
Product.create!(name: "Monitor", author: "User", date_published:  DateTime.now - (60 * 3))

puts "Seeding complete! Created #{Product.count} products."
