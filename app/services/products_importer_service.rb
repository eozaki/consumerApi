class ProductsImporterService
  class << self
    def import(collection)
      binding.pry
      collection.each_slice(collection.size / 5) do |chunk| # 5 is the number of sidekiq threads, should be parametrized
        ImportProductsJob.perform_async(chunk)
      end
    end
  end
end
