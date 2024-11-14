class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :country
      t.string :brand
      t.string :product_id
      t.string :model
      t.string :shop_name
      t.string :product_category_id
      t.decimal :price, precision: 10, scale: 2
      t.string :url
      t.string :compound_key

      t.timestamps

    end

    add_index :products, [:country, :product_id, :shop_name], unique: true
    add_index :products, :compound_key, unique: true
  end
end
