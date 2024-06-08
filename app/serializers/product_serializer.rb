class ProductSerializer < BaseSerializer
  attribute :category do |object|
    object.category.name
  end

  attributes(:name, :description, :code, :total_price)

  attribute :display_picture do |object|
    host = Rails.env.test? ? 'http://localhost:3000' : 'https://srv501805.hstgr.cloud'
    host + Rails.application.routes.url_helpers.rails_blob_path(object.display_picture, only_path: true) if object.display_picture.attached?
  end

  attribute :product_variants do |object|
    object.product_variants
  end
end
