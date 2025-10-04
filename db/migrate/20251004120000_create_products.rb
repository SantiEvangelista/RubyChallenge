class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :author, null: false
      t.datetime :date_published, null: true
      t.timestamps # Esto ya incluye created_at y updated_at
    end
  end
end
