# db/migrate/20251004130000_add_status_to_products.rb
class AddStatusToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :status, :string, default: 'pending', null: false
  end
end
