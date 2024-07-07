class CartProductSerializer < BaseSerializer
  attributes :product_id, :product_variant_id
  
  attribute :product_category do |object|
    object.product.category.name
  end

  attribute :product_display_picture do |object|
    base_url + Rails.application.routes.url_helpers.rails_blob_path(object.product.display_picture, only_path: true) if object.product.display_picture.attached?
  end

  attribute :product_name do |object|
    object.product.name
  end

  attribute :product_code do |object|
    object.product.code
  end

  attribute :product_manufacturer do |object|
    object.product.manufacturer
  end

  attribute :product_dosage do |object|
    object.product.dosage
  end

  attribute :product_features do |object|
    object.product.features
  end

  attribute :product_variant_size do |object|
    object.product_variant.size
  end

  attribute :product_variant_price do |object|
    object.product_variant.price
  end

  attribute :product_variant_quantity do |object|
    object.product_variant.quantity
  end

  attribute :product_variant_carted_quantity do |object|
    object.quantity
  end

  attribute :product_variant_carted_price do |object|
    object.product_variant.price * object.quantity
  end

  attributes :created_at, :updated_at
end
