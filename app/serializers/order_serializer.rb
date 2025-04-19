class OrderSerializer < BaseSerializer
  attributes :payment_method, :payment_status, :order_status, :total_amount, :razorpay_order_id, :razorpay_payment_id, :placed_at, :cancelled_at, :paid_at, :created_at

  attribute :address do |order|
    {
      id: order.address.id,
      name: order.address.name,
      mobile: order.address.mobile,
      pincode: order.address.pincode,
      state: order.address.state,
      district: order.address.district,
      address: order.address.address
    }
  end

  attribute :products do |order|
    order.order_products.map do |op|
      variant = op.product_variant
      product = variant.product

      {
        product_id: product.id,
        product_name: product.name,
        product_description: product.description,
        variant_id: variant.id,
        variant_size: variant.size,
        quantity: op.quantity,
        price: op.price,
        total_price: op.total_price,
        product_image_url: product.product_image.attached? ? Rails.application.routes.url_helpers.rails_blob_url(product.product_image, only_path: true) : nil,
        image_urls: product.images.map { |img| Rails.application.routes.url_helpers.rails_blob_url(img, only_path: true) }
      }
    end
  end
end
