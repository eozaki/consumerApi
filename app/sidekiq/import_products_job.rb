class ImportProductsJob
  include Sidekiq::Job

  def perform(products_json_array)
    query = collection_to_query(products_json_array)

    ActiveRecord::Base.connection.execute(query)
  end

  def collection_to_query(collection)
    q = "INSERT INTO #{Product.table_name} (" \
      "country, brand, product_id, model, " \
      "shop_name, product_category_id, price, " \
      "url, created_at, updated_at" \
      ") VALUES \n"

    q = q + collection.map do |product|
      "(" \
        "'#{product['country']}', '#{product['brand']}', '#{product['product_id']}', " \
        "'#{product['model']}', '#{product['shop_name']}', '#{product['product_category_id']}', " \
        "'#{product['price']}', '#{product['url']}', " \
        "'#{Time.now}', '#{Time.now}'" \
        ")"
    end.join(",\n")

    q = q + "\nON CONFLICT(country, product_id, shop_name)\n" \
      "DO UPDATE SET\n" \
      "country = EXCLUDED.country,\n" \
      "brand = EXCLUDED.brand,\n" \
      "product_id = EXCLUDED.product_id,\n" \
      "model = EXCLUDED.model,\n" \
      "shop_name = EXCLUDED.shop_name,\n" \
      "product_category_id = EXCLUDED.product_category_id,\n" \
      "price = EXCLUDED.price,\n" \
      "url = EXCLUDED.url,\n" \
      "updated_at = EXCLUDED.updated_at;\n"

    q
  end

end

