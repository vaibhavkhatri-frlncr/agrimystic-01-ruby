class ProductSerializer < BaseSerializer
  attribute :category do |object|
    object.category.name
  end

  attribute :display_picture do |object|
    host + Rails.application.routes.url_helpers.rails_blob_path(object.display_picture, only_path: true) if object.display_picture.attached?
  end

  attributes(:name, :code, :manufacturer, :dosage, :features, :description, :total_price)

  attribute :options do |object|
    object.product_variants.count
  end

  attribute :images do |object|
    if object.images.attached?
      object.images.map do |image|
        host + Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
      end
    else
      []
    end
  end

  attribute :product_variants do |object|
    object.product_variants
  end

  private

  def self.host
    Rails.env.test? ? 'http://localhost:3000' : 'https://srv501805.hstgr.cloud'
  end
end
