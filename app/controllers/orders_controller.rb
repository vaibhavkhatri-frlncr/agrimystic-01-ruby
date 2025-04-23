class OrdersController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :set_order, only: [:cancel, :process_payment, :payment_verification]

  def index
    orders = current_user.orders.includes(order_products: { product_variant: :product }, address: {}).order(created_at: :desc)

    if orders.any?
      render json: OrderSerializer.new(orders).serializable_hash, status: :ok
    else
      render json: { errors: [{ message: 'No orders found.' }] }, status: :not_found
    end
  end

  def create
    payment_method = params[:payment_method]
    address_id = params[:address_id]
    product_variant_id = params[:product_variant_id] # Optional
    quantity = params[:quantity].to_i > 0 ? params[:quantity].to_i : 1

    address = current_user.addresses.find_by(id: address_id)
    return render json: { errors: [{ message: 'Address not found.' }] }, status: :not_found unless address

    ActiveRecord::Base.transaction do
      # Buy Now Flow (Single item)
      if product_variant_id.present?
        variant = ProductVariant.find_by(id: product_variant_id)
        return render json: { errors: [{ message: 'Product variant not found.' }] }, status: :not_found unless variant

        if variant.quantity < quantity
          return render json: { errors: [{ message: "Only #{variant.quantity} unit(s) available in stock." }] }, status: :unprocessable_entity
        end

        total_amount = variant.price * quantity
      else
        # Cart Flow
        cart = current_user.cart
        return render json: { errors: [{ message: 'Cart is empty.' }] }, status: :unprocessable_entity if cart.cart_products.empty?
        total_amount = cart.total_price
      end

      order = Order.create!(
        account_id: current_user.id,
        address_id: address.id,
        payment_method: payment_method,
        payment_status: 'pending',
        order_status: 'placed',
        total_amount: total_amount,
        placed_at: Time.current
      )

      if product_variant_id.present?
        OrderProduct.create!(
          order_id: order.id,
          product_variant_id: variant.id,
          quantity: quantity,
          price: variant.price,
          total_price: variant.price * quantity
        )
        variant.update!(quantity: variant.quantity - quantity)
      else
        current_user.cart.cart_products.each do |cart_product|
          OrderProduct.create!(
            order_id: order.id,
            product_variant_id: cart_product.product_variant_id,
            quantity: cart_product.quantity,
            price: cart_product.product_variant.price,
            total_price: cart_product.product_variant.price * cart_product.quantity
          )

          cart_product.product_variant.update!(
            quantity: cart_product.product_variant.quantity - cart_product.quantity
          )
        end
      end

      # Clear cart if cart flow
      if product_variant_id.blank?
        current_user.cart.cart_products.destroy_all
        current_user.cart.update!(total_price: 0.0)
      end

      if payment_method == 'online'
         render json: {
          message: 'Order created successfully.',
          order_id: order.id,
        }, status: :ok
      else
        render json: {
          message: 'Order placed successfully with Cash on Delivery.',
          order_id: order.id
        }, status: :ok
      end
    end
  rescue Razorpay::Error => e
    render json: { errors: [{ message: "Razorpay error: #{e.message}" }] }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: [{ message: e.record.errors.full_messages.join(", ") }] }, status: :unprocessable_entity
  end

  def cancel
    if @order.nil?
      return render json: { errors: [{ message: 'Order not found.' }] }, status: :not_found
    end

    if @order.order_status == 'cancelled'
      return render json: { errors: [{ message: 'Order is already cancelled.' }] }, status: :unprocessable_entity
    end

    if @order.order_status != 'placed'
      return render json: { errors: [{ message: 'Order cannot be cancelled now.' }] }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      @order.update!(order_status: 'cancelled', cancelled_at: Time.current)

      # Restock products
      @order.order_products.each do |op|
        variant = op.product_variant
        variant.update!(quantity: variant.quantity + op.quantity)
      end
    end

    render json: { message: 'Order cancelled successfully.' }, status: :ok
  rescue => e
    render json: { errors: [{ message: e.message }] }, status: :unprocessable_entity
  end

  def process_payment
    if @order.nil?
      return render json: { errors: [{ message: 'Order not found.' }] }, status: :not_found
    end

    if @order.payment_status == 'completed'
      return render json: { errors: [{ message: 'Payment already completed.' }] }, status: :unprocessable_entity
    end

    begin
      options = {
        amount: (@order.total_amount * 100).to_i,
        currency: 'INR',
        receipt: "order_#{@order.id}"
      }

      # Create Razorpay order if one doesn't exist yet
      unless @order.razorpay_order_id.present?
        razorpay_order = Razorpay::Order.create(options)
        @order.update!(razorpay_order_id: razorpay_order.id)
      else
        # Get existing order details from Razorpay
        razorpay_order = Razorpay::Order.fetch(@order.razorpay_order_id)
      end

      render json: {
        success: true,
        order: {
          id: razorpay_order.id,
          amount: razorpay_order.amount / 100.0,
          currency: razorpay_order.currency
        }
      }, status: :ok
    rescue Razorpay::Error => e
      render json: { errors: [{ message: "Razorpay error: #{e.message}" }] }, status: :unprocessable_entity
    end
  end

  def razorpay_api_key
    key = Rails.configuration.razorpay[:key_id]

    if key.present?
      render json: { key: key }, status: :ok
    else
      render json: { error: 'Razorpay key not configured.' }, status: :unprocessable_entity
    end
  end

  def payment_verification
    if @order.nil?
      return render json: { errors: [{ message: 'Order not found.' }] }, status: :not_found
    end

    razorpay_payment_id = params[:razorpay_payment_id]
    razorpay_order_id = params[:razorpay_order_id]
    razorpay_signature = params[:razorpay_signature]

    # Create signature body
    body = "#{razorpay_order_id}|#{razorpay_payment_id}"

    # Calculate expected signature
    expected_signature = OpenSSL::HMAC.hexdigest('sha256', ENV['RAZORPAY_API_SECRET'], body)

    # Verify signature
    is_authentic = expected_signature == razorpay_signature

    if is_authentic
      # Update order with payment info
      @order.update!(
        payment_status: 'completed',
        razorpay_payment_id: razorpay_payment_id,
        paid_at: Time.current
      )
      render json: { success: true, message: 'Payment verified' }, payment_id: :razorpay_payment_id
    else
      render json: { success: false, message: 'Payment verification failed' }, status: :bad_request
    end
  rescue => e
    render json: { errors: [{ message: e.message }] }, status: :unprocessable_entity
  end

  private

  def set_order
    @order = current_user.orders.find_by(id: params[:id].to_i)
  end
end
