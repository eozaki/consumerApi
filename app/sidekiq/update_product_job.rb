class UpdateProductJob
  include Sidekiq::Job

  def perform(prods_to_update)
    Product.update(prods_to_update.map { |p| p[:id] }, prods_to_update)
  end
end
