class ImportProductsJob
  include Sidekiq::Job

  def perform(products_json_array)
    Product
      .create_with(products_json_array)
      .find_or_create_by(compound_key: products_json_array.map { |e| e['compound_key'] })
  end
end
