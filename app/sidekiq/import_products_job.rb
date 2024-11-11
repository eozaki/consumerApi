class ImportProductsJob
  include Sidekiq::Job

  def perform(products_json_array)
    products = products_json_array.map do |entry|
      {
        country: entry['country'],
        brand: entry['brand'],
        product_id: entry['sku'],
        model: entry['model'],
        shop_name: entry['site'] || entry['marketplaceseller'],
        product_category_id: entry['categoryId'],
        price: entry['price'],
        url: entry['url'],
      }

      Product.create(products)
    end
  end
end
