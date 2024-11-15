class ImportProductsJob
  include Sidekiq::Job

  def perform(products_json_array)
    Product.import(products_json_array)
  end
end
