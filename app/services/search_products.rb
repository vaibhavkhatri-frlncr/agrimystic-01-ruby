class SearchProducts
  def self.search_records(query)
    query = query.downcase
    @results = Product.where(
      "lower(name) LIKE :q OR
       lower(description) LIKE :q OR
       lower(code) LIKE :q OR
       CAST(total_price AS TEXT) LIKE :q OR
       lower(manufacturer) LIKE :q OR
       lower(dosage) LIKE :q OR
       lower(features) LIKE :q",
      q: "%#{query}%"
    )
    return @results
  end 
end
