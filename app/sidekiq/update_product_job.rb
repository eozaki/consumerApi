class UpdateProductJob
  include Sidekiq::Job

  def perform(prods_to_update)
    payload = {}
    prods_to_update.each do |id, prod|
      payload[id] = prod
    end

    Product.update(payload.keys, payload.values)
  end
end
