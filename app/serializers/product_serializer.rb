class ProductSerializer < BaseSerializer
  attribute :category do |product|
    product.category.name
  end

  attribute :product_image do |product|
    base_url + Rails.application.routes.url_helpers.rails_blob_path(product.product_image, only_path: true) if product.product_image.attached?
  end

  attributes :name, :code, :manufacturer, :dosage, :features, :description, :total_price

  attribute :options do |product|
    product.product_variants.count
  end

  attribute :images do |product|
    if product.images.attached?
      product.images.map do |image|
        base_url + Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
      end
    else
      []
    end
  end
  
  attributes :created_at, :updated_at, :product_variants
end
