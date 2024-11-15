class ProductsImporterService
  class << self
    def import(file)
      collection = sanitize_data(JSON(file.read.encode('UTF-8', 'ISO-8859-1')))

      to_update = {}
      prods = Product
        .where(compound_key: collection.map { |_, e| e['compound_key'] })
      
      if prods.present?
        prods.each do |p|
          to_update[p.id] = collection[p.compound_key]
        end
      end

      if to_update.present?
        to_update.to_a.each_slice(to_update.size / 5) do |chunk|
          UpdateProductJob.perform_async(chunk)
        end
      end

      to_update.each do |_, u|
        collection.delete u['compound_key']
      end

      if collection.present?
        collection.values.each_slice(collection.size / 5) do |chunk|
          ImportProductsJob.perform_async(chunk.flatten)
        end
      end
    end

    def sanitize_data(collection)
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
