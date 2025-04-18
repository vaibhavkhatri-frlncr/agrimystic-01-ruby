class CartProductSerializer < BaseSerializer
  attributes :product_id, :product_variant_id
  
  attribute :product_category do |cart_product|
    cart_product.product.category.name
  end

  attribute :product_image do |cart_product|
    base_url + Rails.application.routes.url_helpers.rails_blob_path(cart_product.product.product_image, only_path: true) if cart_product.product.product_image.attached?
  end

  attribute :product_name do |cart_product|
    cart_product.product.name
  end

  attribute :product_code do |cart_product|
    cart_product.product.code
  end

  attribute :product_manufacturer do |cart_product|
    cart_product.product.manufacturer
  end

  attribute :product_dosage do |cart_product|
    cart_product.product.dosage
  end

  attribute :product_features do |cart_product|
    cart_product.product.features
  end

  attribute :product_variant_size do |cart_product|
    cart_product.product_variant.size
  end

  attribute :product_variant_price do |cart_product|
    cart_product.product_variant.price
  end

  attribute :product_variant_quantity do |cart_product|
    cart_product.product_variant.quantity
  end

  attribute :product_variant_carted_quantity do |cart_product|
    cart_product.quantity
  end

  attribute :product_variant_carted_price do |cart_product|
    cart_product.product_variant.price * cart_product.quantity
  end

  attributes :created_at, :updated_at
end
