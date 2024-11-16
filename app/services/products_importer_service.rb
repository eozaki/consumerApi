class ProductsImporterService
  class << self
    def import(file)
      collection = sanitize_data(JSON(file.read.encode('UTF-8', 'ISO-8859-1')))

      collection.values.each_slice(collection.size / 5) do |chunk|
        ImportProductsJob.perform_async(chunk)
      end
    end

    def sanitize_data(collection)
      # This Regex could be something like a class constant,
      # but it is only used in here and specifically in the process of sanitizing data
      exclusion_regex = /(\ *BE(\ +|$)|\ *NL(\ +|$)|\ *PT(\ +|$)|\ *FR(\ +|$)|\ *DE(\ +|$))/i

      sanitized = {}
      collection.each do |entry|
        e = {
          'country' => entry['country']&.gsub(exclusion_regex, ''),
          'product_id' => entry['sku'],
          'shop_name' =>
            entry['site']&.gsub(exclusion_regex, '') || entry['marketplaceseller'].gsub(exclusion_regex, ''),

          'brand' => entry['brand']&.gsub(exclusion_regex, ''),
          'model' => entry['model']&.gsub(exclusion_regex, ''),
          'product_category_id' => entry['categoryId'],
          'price' => entry['price'],
          'url' => entry['url'],
          'compound_key' =>
            "#{(entry['site'] || entry['marketplaceseller']).upcase&.gsub(exclusion_regex, '')}" \
            "#{(entry['country']).upcase&.gsub(exclusion_regex, '')}" \
            "#{entry['sku']}",
        }

        sanitized[e['compound_key']] = e
      end

      sanitized
    end
  end
end
