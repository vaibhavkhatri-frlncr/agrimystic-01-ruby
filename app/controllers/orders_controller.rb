class OrdersController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :set_order, only: %i[cancel process_payment payment_verification]

  def index
    orders = current_user.orders.includes(order_products: { product_variant: :product }, address: {}).order(created_at: :desc)

    if orders.any?
      render json: OrderSerializer.new(orders).serializable_hash, status: :ok
    else
      render json: { errors: [{ message: 'No orders found.' }] }, status: :not_found
    end
  end

  def create
    payment_method       = order_params[:payment_method]
    address              = current_user.addresses.find_by(id: order_params[:address_id])
    variant_id           = order_params[:product_variant_id]
    quantity             = order_params[:quantity].to_i.positive? ? order_params[:quantity].to_i : 1

    return render(json: { errors: [{ message: 'Address not found.' }] }, status: :not_found) unless address

    ActiveRecord::Base.transaction do
      if variant_id.present?
        variant = ProductVariant.find_by(id: variant_id)
        return render(json: { errors: [{ message: 'Product variant not found.' }] }, status: :not_found) unless variant

        if variant.quantity < quantity
          return render(json: { errors: [{ message: "Only #{variant.quantity} unit(s) available in stock." }] }, status: :unprocessable_entity)
        end

        total_amount = variant.price * quantity
      else
        cart = current_user.cart
        if cart.cart_products.empty?
          return render(json: { errors: [{ message: 'Cart is empty.' }] }, status: :unprocessable_entity)
        end

        total_amount = cart.total_price
      end

      order = current_user.orders.create!(
        address: address,
        payment_method: payment_method,
        payment_status: 'pending',
        order_status: 'placed',
        total_amount: total_amount,
        placed_at: Time.current
      )

      if variant_id.present?
        order.order_products.create!(
          product_variant: variant,
          quantity: quantity,
          price: variant.price,
          total_price: variant.price * quantity
        )
        variant.decrement!(:quantity, quantity)
      else
        current_user.cart.cart_products.find_each do |cart_product|
          variant = cart_product.product_variant
          order.order_products.create!(
            product_variant: variant,
            quantity: cart_product.quantity,
            price: variant.price,
            total_price: variant.price * cart_product.quantity
          )
          variant.decrement!(:quantity, cart_product.quantity)
        end

        current_user.cart.cart_products.destroy_all
        current_user.cart.update!(total_price: 0.0)
      end

      status_message = if payment_method == 'online'
                         { message: 'Order created successfully.', order_id: order.id }
                       else
                         { message: 'Order placed successfully with Cash on Delivery.', order_id: order.id }
                       end

      render json: status_message, status: :ok
    end
  rescue Razorpay::Error => e
    render json: { errors: [{ message: "Razorpay error: #{e.message}" }] }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: [{ message: e.record.errors.full_messages.join(', ') }] }, status: :unprocessable_entity
  end

  def cancel
    return render(json: { errors: [{ message: 'Order not found.' }] }, status: :not_found) unless @order
    return render(json: { errors: [{ message: 'Order is already cancelled.' }] }, status: :unprocessable_entity) if @order.cancelled?
    return render(json: { errors: [{ message: 'Order cannot be cancelled now.' }] }, status: :unprocessable_entity) unless @order.placed?

    ActiveRecord::Base.transaction do
      @order.update!(order_status: 'cancelled', cancelled_at: Time.current)
      @order.order_products.each do |op|
        op.product_variant.increment!(:quantity, op.quantity)
      end
    end

    render json: { message: 'Order cancelled successfully.' }, status: :ok
  rescue StandardError => e
    render json: { errors: [{ message: e.message }] }, status: :unprocessable_entity
  end

  def process_payment
    return render(json: { errors: [{ message: 'Order not found.' }] }, status: :not_found) unless @order
    return render(json: { errors: [{ message: 'Order is not set for online payment.' }] }, status: :unprocessable_entity) if @order.payment_method != 'online'
    return render(json: { errors: [{ message: 'Payment already completed.' }] }, status: :unprocessable_entity) if @order.completed?

    options = {
      amount: (@order.total_amount * 100).to_i,
      currency: 'INR',
      receipt: "order_#{@order.id}"
    }

    razorpay_order = if @order.razorpay_order_id.present?
                       Razorpay::Order.fetch(@order.razorpay_order_id)
                     else
                       new_order = Razorpay::Order.create(options)
                       @order.update!(razorpay_order_id: new_order.id)
                       new_order
                     end

    render json: { success: true, order: { id: razorpay_order.id, amount: razorpay_order.amount, currency: razorpay_order.currency } }, status: :ok
  rescue Razorpay::Error => e
    render json: { errors: [{ message: "Razorpay error: #{e.message}" }] }, status: :unprocessable_entity
  end

  def razorpay_api_key
    key = Rails.configuration.razorpay[:key_id]

    if key.present?
      render json: { key: key }, status: :ok
    else
      render json: { errors: [{ message: 'Razorpay key not configured.' }] }, status: :unprocessable_entity
    end
  end

  def payment_verification
    return render(json: { errors: [{ message: 'Order not found.' }] }, status: :not_found) unless @order
    return render(json: { success: true, message: 'Payment already verified', payment_id: @order.razorpay_payment_id }, status: :ok) if @order.completed?

    razorpay_payment_id = params[:razorpay_payment_id]
    razorpay_order_id   = params[:razorpay_order_id]
    razorpay_signature  = params[:razorpay_signature]

    if razorpay_payment_id.blank? || razorpay_order_id.blank? || razorpay_signature.blank?
      return render json: { success: false, message: 'Missing payment parameters' }, status: :bad_request
    end

    unless @order.razorpay_order_id == razorpay_order_id
      return render json: { success: false, message: 'Order ID mismatch' }, status: :bad_request
    end

    begin
      payment_attrs = {
        razorpay_order_id:   razorpay_order_id,
        razorpay_payment_id: razorpay_payment_id,
        razorpay_signature:  razorpay_signature
      }
      if Razorpay::Utility.verify_payment_signature(payment_attrs)
        ActiveRecord::Base.transaction do
          payment = Razorpay::Payment.fetch(razorpay_payment_id)
          if (payment.amount / 100.0) != @order.total_amount
            raise "Payment amount mismatch: expected #{@order.total_amount}, got #{payment.amount / 100.0}"
          end
          @order.update!(payment_status: 'completed', order_status: 'processing', razorpay_payment_id: razorpay_payment_id, paid_at: Time.current)
        end
        render json: { success: true, message: 'Payment verified successfully', payment_id: razorpay_payment_id }, status: :ok
      else
        render json: { success: false, message: 'Payment signature verification failed' }, status: :bad_request
      end
    rescue Razorpay::Error => e
      render json: { success: false, message: "Razorpay error: #{e.message}" }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { errors: [{ message: e.message }] }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = current_user.orders.find_by(id: params[:id])
  end

  def order_params
    params.permit(:payment_method, :address_id, :product_variant_id, :quantity)
  end
end
